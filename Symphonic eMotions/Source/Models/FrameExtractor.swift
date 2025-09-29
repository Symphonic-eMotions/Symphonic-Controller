//
//  FrameExtractor.swift

import AVFoundation
import Combine
import CoreImage.CIFilterBuiltins
import UIKit

enum CameraError: Error {
    case noCameraAvailable
}

private let _shared = FrameExtractor()

protocol FrameExtractorDelegate: AnyObject {
    func captured(image: CIImage)
}

class FrameExtractor: NSObject {
    static let shared = FrameExtractor()

    private let position = AVCaptureDevice.Position.front
    private let quality = AVCaptureSession.Preset.vga640x480

    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let bufferQueue = DispatchQueue(label: "buffer queue")
    private let captureSession = AVCaptureSession()

    private let context = CIContext()

    let previewLayer: AVCaptureVideoPreviewLayer
    private var imagePreviewView: UIImageView!

    weak var delegate: FrameExtractorDelegate?

    private var orientation: UIInterfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? .unknown {
        didSet {
            guard oldValue != orientation else { return }
            setConnectionOrientation()
        }
    }

    deinit {
        captureSession.stopRunning()
        NotificationCenter.default.removeObserver(self)
    }

    override fileprivate init() {
        UIApplication.shared.isIdleTimerDisabled = true
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        super.init()

        // Observer toevoegen voor oriëntatieveranderingen
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

        checkPermission()
        startExtracting()
    }

    @objc private func orientationChanged() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        orientation = windowScene.interfaceOrientation
    }

    func startExtracting() {
        sessionQueue.async {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.configureSession()
                self.captureSession.startRunning()
            }
        }
    }

    func stopExtracting() {
        captureSession.stopRunning()
    }

    // MARK: AVSession configuratie

    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }

    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }

    private func configureSession() {
        guard permissionGranted else {
            print("Error: Geen toestemming verleend")
            return
        }
        captureSession.sessionPreset = quality

        switch selectCaptureDevice() {
        case let .success(captureDevice):
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)

                guard captureSession.canAddInput(captureDeviceInput) else {
                    print("Error: Kan input niet toevoegen aan captureSession")
                    return
                }
                captureSession.addInput(captureDeviceInput)

                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(self, queue: bufferQueue)

                guard captureSession.canAddOutput(videoOutput) else {
                    print("Error: Kan output niet toevoegen aan captureSession")
                    return
                }
                captureSession.addOutput(videoOutput)
                setConnectionOrientation()

            } catch {
                print("Error: Kan captureDeviceInput niet initialiseren:", error)
            }

        case let .failure(error):
            switch error {
            case .noCameraAvailable:
                print("Error: Geen camera beschikbaar")
            }
        }
    }

    private func setConnectionOrientation() {
        guard let videoOutput = captureSession.outputs.first else { return }

        guard let connection = videoOutput.connection(with: AVMediaType.video) else {
            print("Error: Geen videoOutput verbinding")
            return
        }
        guard connection.isVideoOrientationSupported else {
            print("Error: Video oriëntatie niet ondersteund")
            return
        }
        guard connection.isVideoMirroringSupported else {
            print("Error: Video mirroring niet ondersteund")
            return
        }

        let videoOrientation: AVCaptureVideoOrientation = {
            switch orientation {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            default: return .portrait
            }
        }()

        connection.videoOrientation = videoOrientation
        connection.automaticallyAdjustsVideoMirroring = false
        connection.isVideoMirrored = position == .front

        // Update de oriëntatie van de previewLayer
        DispatchQueue.main.async {
            if let previewConnection = self.previewLayer.connection {
                if previewConnection.isVideoOrientationSupported {
                    previewConnection.videoOrientation = videoOrientation
                }
                if previewConnection.isVideoMirroringSupported {
                    previewConnection.automaticallyAdjustsVideoMirroring = false
                    previewConnection.isVideoMirrored = self.position == .front
                }
            }
        }
    }

    private func selectCaptureDevice() -> Result<AVCaptureDevice, CameraError> {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            print("builtInWideAngleCamera")
            return .success(device)
        } else if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .front) {
            print("builtInDualCamera")
            return .success(device)
        } else {
            print("Error: Geen geschikte camera gevonden")
            return .failure(.noCameraAvailable)
        }
    }

    // MARK: Sample buffer naar UIImage conversie

    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        return CIImage(cvPixelBuffer: imageBuffer)
    }
}

extension FrameExtractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        guard let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        delegate?.captured(image: image)
    }
}
