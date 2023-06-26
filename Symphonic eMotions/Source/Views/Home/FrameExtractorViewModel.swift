//
//  FrameExtractorViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/06/2023.
//

import SwiftUI

class FrameExtractorViewModel: FrameExtractorDelegate, ObservableObject {
    
    @Published var image: CIImage? = nil
    
    let frameExtractor: FrameExtractor = FrameExtractor.shared
        
    init() {
        self.frameExtractor.delegate = self
    }
    
    func captured(image: CIImage) {
        DispatchQueue.main.async {
            self.image = image
        }
    }
    
//    let frameExtractor: FrameExtractor
//
//    init() {
//        self.frameExtractor = FrameExtractor.shared
//        self.frameExtractor.delegate = self
//    }
//
//    func captured(image: CIImage) {
//        DispatchQueue.main.async {
//            self.image = image
//        }
//    }
    
    func calculateAverageBrightness(ciImage: CIImage) -> Double {
        // Create a 1x1 bitmap image context for sampling from the image
        let context = CIContext(options: nil)
        let pixelSize = CGSize(width: 1, height: 1)
        
        let outputImage = ciImage.transformed(by: CGAffineTransform(scaleX: 1/ciImage.extent.size.width, y: 1/ciImage.extent.size.height))
        
        guard let cgImage = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: pixelSize)) else {
            return 0.0
        }
        
        // Create a 1x1 pixel bitmap context and render the CGImage into it
        let bitmapData = calloc(1, 4)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        let bitmapContext = CGContext(data: bitmapData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue)
        
        bitmapContext?.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        // Calculate the average brightness from the pixel data
        let pixelData = bitmapData!.assumingMemoryBound(to: UInt8.self)
        let red = Double(pixelData[0])
        let green = Double(pixelData[1])
        let blue = Double(pixelData[2])
        
        // Clean up
        free(bitmapData)
        
        // Return the average brightness (assuming RGB values are in the range 0-255)
        return (red + green + blue) / 3.0
    }
}
    
    
    
//
//    func calculateAvgWhiteValue(_ image: CIImage) -> Double {
//        // Convert image to grayscale
//        let grayImage = image.applyingFilter(CIFilter.colorMonochrome().name , parameters: [
//            kCIInputImageKey: image,
//            kCIInputIntensityKey: 1.0,
//            "inputColor": CIColor(red: 0.5, green: 0.5, blue: 0.5)
//        ])
//        // Calculate average white value
//        if let cgImage = CIContext().createCGImage(grayImage, from: grayImage.extent) {
//            return self.calculateAvgWhiteValue(cgImage)
//        }
//        return 0.0
//    }
//
//    private func calculateAvgWhiteValue(_ image: CGImage) -> Double {
//        let pixelData = image.dataProvider?.data
//        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
//
//        var sum: UInt64 = 0
//        let height = image.height
//        let width = image.width
//        let bytesPerRow = image.bytesPerRow
//
//        for y in 0 ..< height {
//            let i = y * bytesPerRow
//            for x in 0 ..< width {
//                let index = i + x * 4
//                let pixel: UInt32 = UInt32(data[index])
//                sum += UInt64(pixel)
//            }
//        }
//        let totalPixels = width * height
//        let avgValue = Double(sum) / Double(totalPixels)
//        return avgValue
//    }

