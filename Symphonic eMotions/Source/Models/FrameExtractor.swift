//
//  FrameExtractor.swift

import UIKit
import AVFoundation
import Combine
import CoreImage.CIFilterBuiltins

private let _shared = FrameExtractor()

protocol FrameExtractorDelegate: AnyObject {
    func captured(image: CIImage)
}

class FrameExtractor: NSObject {
    
    static var shared: FrameExtractor { _shared }
    
    private let position = AVCaptureDevice.Position.front
    private let quality = AVCaptureSession.Preset.vga640x480
    
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let bufferQueue = DispatchQueue(label: "buffer queue")
    private let captureSession = AVCaptureSession()
    
    private let context = CIContext()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var imagePreviewView: UIImageView!
    
    weak var delegate: FrameExtractorDelegate?
    
    private var orientation: UIInterfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? .unknown {
        didSet {
            guard oldValue != orientation else { return }
            setConnectionOrientation()
        }
    }
    
    private var listener: AnyCancellable?
    
    deinit {
//        listener?.cancel()
        captureSession.stopRunning()
    }
    
    fileprivate override init() {
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        super.init()
        
        checkPermission()
        startExtracting()
    }
    
    public func startExtracting(){
        sessionQueue.async {
//            DispatchQueue.global(qos: .background).async { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.configureSession()
                self.captureSession.startRunning()
                
//                self.listener = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
//                    .compactMap { _ in (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? .unknown }
//                    .assign(to: \.orientation, on: self)
            }
        }
    }
    
    public func stopExtracting(){
        captureSession.stopRunning()
    }
    
    // MARK: AVSession configuration
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
            print("Error: No permissionGranted")
            return
        }
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else {
            print("Error: No captureDevice")
            return
        }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Error: No captureDeviceInput")
            return
        }
        guard captureSession.canAddInput(captureDeviceInput) else {
            print("Error: No captureSession")
            return
        }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: bufferQueue)
        guard captureSession.canAddOutput(videoOutput) else {
            print("Error: No captureSession.canAddOutput")
            return
        }
        captureSession.addOutput(videoOutput)
        setConnectionOrientation()
    }
    
    private func setConnectionOrientation() {
        guard let videoOutput = captureSession.outputs.first else { return }
        
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else {
            print("Error: No videoOutput.connection")
            return
        }
        guard connection.isVideoOrientationSupported else {
            print("Error: No connection.isVideoOrientationSupported")
            return
        }
        guard connection.isVideoMirroringSupported else {
            print("Error: No connection.isVideoMirroringSupported")
            return
        }
        
        connection.videoOrientation = {
            switch orientation {
            case .landscapeRight: return .landscapeRight
            case .landscapeLeft: return .landscapeLeft
            default: return .portrait
            }
        }()
        
        connection.isVideoMirrored = position == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            print("builtInWideAngleCamera")
            return device
        } else if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .front) {
            print("builtInDualCamera")
            return device
        } else {
            print("Error: No selectCaptureDevice (.video .front)")
            fatalError("Missing expected front camera device.")
        }
    }
    
    // MARK: Sample buffer to UIImage conversion
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        return CIImage(cvPixelBuffer: imageBuffer)
    }
    
    func displayPreview(on view: UIView) throws {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.previewLayer == nil {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer?.videoGravity = .resizeAspectFill
            }
            
            DispatchQueue.main.async {
                view.layer.insertSublayer(self.previewLayer!, at: 0)
                self.previewLayer?.frame = view.frame
                self.previewLayer?.connection?.videoOrientation = {
                    switch (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation {
                    case .landscapeRight: return .landscapeRight
                    case .landscapeLeft: return .landscapeLeft
                    default: return .portrait
                    }
                }()
            }
        }
    }
}

extension FrameExtractor: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // print("FJW: After 12 set switches data is no longer ariving at this spot.")
        
        guard let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        self.delegate?.captured(image: image)
    }
}
