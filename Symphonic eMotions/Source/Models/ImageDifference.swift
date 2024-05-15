import UIKit
import Combine

protocol ImageDifferenceDelegate: AnyObject {
    func newImageAvailable(_ image: CIImage)
}

protocol ImageDifferenceValuesDelegate: AnyObject {
    func newValueAvailable(_ values: [[AreaValues]])
}

class ImageDifference: ObservableObject {
    weak var delegate: ImageDifferenceDelegate?
    weak var valueDelegate: ImageDifferenceValuesDelegate?
    
    private let rowCount: CGFloat
    private let columnCount: CGFloat
    
    private var previousFrame: CIImage?
    private var previousDiffFrame: CIImage?
    
    var values = CurrentValueSubject<[[AreaValues]], Never>([])
    var sensitivityDeviationSubject = CurrentValueSubject<Float, Never>(0.99)
    var maxValueSubject = CurrentValueSubject<Int, Never>(50)
    var feedback = CurrentValueSubject<Float, Never>(0.50)
    
    // Nieuwe variabelen voor kalibratie
    private var calibrationValues: [Int] = []
    @Published var calibrationThreshold: Int = 0
    @Published var isCalibrating: Bool = false
    private let calibrationSamples: Int = 100 // Aantal samples voor kalibratie
    
    private init(rowCount: Int, columnCount: Int, maxValue: Int = 50, feedback: Float = 0.50) {
        self.rowCount = CGFloat(rowCount)
        self.columnCount = CGFloat(columnCount)
        self.feedback.value = feedback
        self.maxValueSubject.value = maxValue
        values.value = Array(repeating: Array(repeating: AreaValues(value: 0, maxValue: maxValue), count: rowCount), count: columnCount)
    }
    
    convenience init(instrumentsSet: InstrumentsSet) {
        self.init(rowCount: instrumentsSet.rows, columnCount: instrumentsSet.columns)
    }
    
    convenience init(setSetting: SetSettings) {
        self.init(rowCount: setSetting.gridRows, columnCount: setSetting.gridColumns)
    }
    
    func startCalibration() {
        isCalibrating = true
        resetCalibrationValues()
    }
    
    func stopCalibration() {
        isCalibrating = false
        calibrationThreshold = calculateThreshold(from: calibrationValues)
    }
    
    private func resetCalibrationValues() {
        calibrationValues.removeAll()
        calibrationThreshold = 0
    }
    
    private func calculateThreshold(from values: [Int]) -> Int {
        guard !values.isEmpty else { return 0 }
        let mean = values.reduce(0, +) / values.count
        let deviation = sqrt(Double(values.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / values.count))
        return mean + Int(deviation) // Stel drempel in op gemiddelde + standaarddeviatie
    }
    
    func updateImageData(image: CIImage) {
        var tempAreaValues = values.value
        let edgeFilter = CIFilter.edges()
        edgeFilter.intensity = 1.0
        edgeFilter.inputImage = image
        let edgesImage = edgeFilter.outputImage!
        
        let composite = CIFilter.exclusionBlendMode()
        composite.setValue(image, forKey: kCIInputImageKey)
        composite.setValue(edgesImage, forKey: kCIInputBackgroundImageKey)
        let compositeImage = composite.outputImage!
        
        let monoFilter = CIFilter.colorMonochrome()
        monoFilter.inputImage = compositeImage
        let monoImage = monoFilter.outputImage!
        
        guard let previousFrame = previousFrame else {
            self.previousFrame = monoImage
            return
        }
        
        let diffFilter = CIFilter.differenceBlendMode()
        diffFilter.setValue(monoImage, forKey: kCIInputImageKey)
        diffFilter.setValue(previousFrame, forKey: kCIInputBackgroundImageKey)
        let diffImage = diffFilter.outputImage!
    
        delegate?.newImageAvailable(diffImage)
        
        let averageFilter = CIFilter.areaAverage()
        averageFilter.inputImage = diffImage
        
        let width = CGFloat(image.extent.width) / rowCount
        let height = CGFloat(image.extent.height) / columnCount
                
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var buf: [CUnsignedChar] = Array(repeating: 255, count: 16)
        
        let context = CGContext(data: &buf, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 16, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        let ciContext = CIContext(cgContext: context, options: [CIContextOption.workingColorSpace: colorSpace, CIContextOption.useSoftwareRenderer: false])
        
        for row in 0..<Int(rowCount) {
            for column in 0..<Int(columnCount) {
                let compareRect = CGRect(x: CGFloat(row) * width, y: CGFloat(column) * height, width: width, height: height)
                let extents = CIVector(cgRect: compareRect)
                averageFilter.setValue(extents, forKey: kCIInputExtentKey)
                let valueImage = averageFilter.outputImage!
                
                ciContext.draw(valueImage, in: CGRect(x: 0, y: 0, width: 1, height: 1), from: valueImage.extent)
                
                let maxVal = max(buf[0], max(buf[1], buf[2]))
                let diff = Int(maxVal)
                                
                // Kalibratie mode: verzamel waardes
                if isCalibrating {
                    calibrationValues.append(diff)
                    if calibrationValues.count >= calibrationSamples {
                        stopCalibration()
                    }
                } else {
                    // Normale mode: pas drempelwaarde toe
                    let filteredDiff = max(0, diff - calibrationThreshold)
                    
                    let columnInvert = Int(column * -1 + (Int(columnCount) - 1))
                    let previousValues = tempAreaValues[columnInvert][row]
                    tempAreaValues[columnInvert][row] = previousValues.withNewRawValue(filteredDiff, maxValue: self.maxValueSubject.value, feedback: self.feedback.value)
                }
            }
        }
        
        self.values.value = tempAreaValues
        self.previousFrame = monoImage
    }
    
    //Functions
    func convertFastLinearToScaledFloat(sensitivity: Float) -> Float {
        let clampedValue = max(0, min(sensitivity, 1)) // Clamp the value between 0 and 1
        let exponentialValue = pow(clampedValue, 2) // Apply exponential function (squared)
        let logarithmicValue = log(clampedValue * 99 + 1) // Apply logarithmic function (scaled and shifted)
        let scaledValue = exponentialValue * logarithmicValue * 0.40 + 0.09 // Combine the exponential and logarithmic functions
        return scaledValue
    }


    func exponetialRanged(sensitivity: Float) -> Float {

        let clampedValue = max(0, min(sensitivity, 1)) // Clamp the value between 0 and 1
        let exponentialValue = pow(clampedValue, 2) // Apply exponential function (squared)
//        let logarithmicValue = log10(exponentialValue + 1) / log10(2)
        let reversedValue = 1 - exponentialValue // Reverse the value
        let scaledValue = reversedValue * 0.40 + 0.09 // Scale the value between 0.09 and 0.85
        return scaledValue
    }

    func lineairReverserd(sensitivity: Float) -> Int {
        let clampedValue = max(0, min(sensitivity, 1)) // Clamp the value between 0 and 1
        let reversedValue = 1 - clampedValue // Reverse the value
        let scaledValue = Int(reversedValue * 185) + 15 // Scale the value between 15 and 200
        return scaledValue
    }

    //MARK: 0...1 to 200 and 15
    func sensitivityToMaxValue(sensitivityPlusDeviation: Float) -> Void {

        self.maxValueSubject.send(
            lineairReverserd(sensitivity: sensitivityPlusDeviation)
        )
    }
}
