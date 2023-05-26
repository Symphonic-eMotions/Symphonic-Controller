//
//  ImageDifference.swift
//  ImageDifference
//
//  Created by Marcel Borsten on 29/03/2021.
//

import UIKit
import Combine

protocol ImageDifferenceDelegate: AnyObject {
    
    /// Called when a new difference image is
    /// available
    ///
    /// - Parameter image: The image
    func newImageAvailable(_ image: CIImage)
    
//    func newValue(value: Double, row: Int, column: Int)
}

protocol ImageDifferenceValuesDelegate: AnyObject {
    
    /// Called when new values are available
    /// - Parameter values: The values
    func newValueAvailable(_ values: [[AreaValues]])
}

class ImageDifference {
    
    weak var delegate: ImageDifferenceDelegate?
    weak var valueDelegate: ImageDifferenceValuesDelegate?
    
    private let rowCount: CGFloat
    private let columnCount: CGFloat
    
    private var previousFrame: CIImage?
    private var previousDiffFrame: CIImage?
    
    var values = CurrentValueSubject<[[AreaValues]], Never>([])
    
    var sensitivitySubject = CurrentValueSubject<Float, Never>(0.99)
    
    /// Kan later aan bijvoorbeeld een slider hangen
    var maxValueSubject = CurrentValueSubject<Int, Never>(50)
    /// Kan later aan bijvoorbeeld een slider hangen
    var feedback = CurrentValueSubject<Float, Never>(0.50)
    
    private init(rowCount: Int, columnCount: Int, maxValue: Int = 50, feedback: Float = 0.50) {
        
        self.rowCount = CGFloat(rowCount)
        self.columnCount = CGFloat(columnCount)
        self.feedback.value = feedback
        self.maxValueSubject.value = maxValue
        //Create AreaValues with value set to 0
        values.value = values.value + Array(
            repeating: Array(
                repeating: AreaValues(value: 0, maxValue: maxValue),
                count: rowCount),
            count: columnCount
        )
    }
    
    //old instrument set version
    convenience init(instrumentsSet: InstrumentsSet) {
        self.init(
            rowCount: instrumentsSet.rows,
            columnCount: instrumentsSet.columns
        )
    }
    
    //New set / session settings
    convenience init(setSetting: SetSettings){
        self.init(
            rowCount: setSetting.gridRows,
            columnCount: setSetting.gridColumns
        )
    }
    
    //MARK: Video DSP location
    
    func updateImageData(image: CIImage) {
        var tempAreaValues = values.value
        
        //Add edges for more sensitivity
        let edgeFilter = CIFilter(name: "CIEdges")
        edgeFilter?.setDefaults()
        edgeFilter?.setValue(image, forKey: kCIInputImageKey)
        edgeFilter?.setValue(1.0, forKey: kCIInputIntensityKey)
        let edgesImage = edgeFilter?.value(forKey: kCIOutputImageKey) as! CIImage
        
        let composite = CIFilter(name: "CIExclusionBlendMode")
        composite?.setDefaults()
        composite?.setValue(image, forKey: kCIInputBackgroundImageKey)
        composite?.setValue(edgesImage, forKey: kCIInputImageKey)
        let compositeImage = composite?.value(forKey: kCIOutputImageKey) as! CIImage
        
        // Omzetten naar grijstoon
        let monoFilter = CIFilter(name: "CIColorMonochrome")
        monoFilter?.setDefaults()
        monoFilter?.setValue(compositeImage, forKey: kCIInputImageKey)
        let monoImage = monoFilter?.value(forKey: kCIOutputImageKey) as! CIImage
        
        guard let previousFrame = previousFrame else {
            self.previousFrame = monoImage
            return
        }
        
        // Maak een difference afbeelding tussen huidig en vorig mono frame
        let diffFilter = CIFilter(name: "CIDifferenceBlendMode")!
        diffFilter.setDefaults()
        diffFilter.setValue(monoImage, forKey: kCIInputImageKey)
        diffFilter.setValue(previousFrame, forKey: kCIInputBackgroundImageKey)
        
        let diffImage = diffFilter.value(forKey: kCIOutputImageKey) as! CIImage
    
        delegate?.newImageAvailable( diffImage )
        
        let averageFilter = CIFilter(name: "CIAreaAverage")!
            averageFilter.setDefaults()
            averageFilter.setValue(diffImage, forKey: kCIInputImageKey)
        
        let width = CGFloat(image.extent.width) / rowCount
        let height = CGFloat(image.extent.height) / columnCount
                
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var buf: [CUnsignedChar] = Array<CUnsignedChar>(repeating: 255, count: 16)
        
        let context = CGContext(data: &buf,
                                width: 1,
                                height: 1,
                                bitsPerComponent: 8,
                                bytesPerRow: 16,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)!
        
        let ciContext = CIContext(cgContext: context,
                                  options: [
                                    CIContextOption.workingColorSpace: colorSpace,
                                    CIContextOption.useSoftwareRenderer: false,
                                  ])
        
        for row in 0..<Int(rowCount) {
                        
            for column in 0..<Int(columnCount) {
                
                let compareRect = CGRect(x: CGFloat(row) * width,
                                         y: CGFloat(column) * height,
                                         width: width,
                                         height: height)
                
                let extents = CIVector(cgRect: compareRect)
                averageFilter.setValue(extents, forKey: kCIInputExtentKey)
                
                let valueImage = averageFilter.value(forKey: kCIOutputImageKey) as! CIImage
                
                ciContext.draw(valueImage,
                               in: CGRect(x: 0,
                                          y: 0,
                                          width: 1,
                                          height: 1),
                               from: valueImage.extent)
                
                let maxVal = max(buf[0], max(buf[1], buf[2]))
                let diff = Int(maxVal)
                
                //TODO, place for video noise reduction?
//                print( "row: \(row) column: \(column) -> \(diff)" )
                
                //invert columns for tap grid campability
                //I really thought this should be rows inverted.
                let columnInvert = Int(column * -1 + (Int(columnCount)-1))
                
                let previousValues = tempAreaValues[columnInvert][row]
                
                
                //Vraag: waarom worden hier de previous values gebruikt als huidige waarden?
                //Antwoord: withNewRawValue
                
                tempAreaValues[columnInvert][row] = previousValues.withNewRawValue(
                    diff,
                    maxValue: self.maxValueSubject.value,
                    feedback: self.feedback.value
                )
            }
        }
        self.values.value = tempAreaValues
        //self.valueDelegate?.newValueAvailable(values)

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
    
    //Mark Sensitivity calculations
    func sensitivityToMaxValue(sensitivity: Float) -> Void {
        
        self.maxValueSubject.send( lineairReverserd(sensitivity: sensitivity) )
    }
    
    func sensitivityToFeedback(sensitivity: Float) -> Void {
        
        self.feedback.send(exponetialRanged(sensitivity: sensitivity))
    }
    
    
}
