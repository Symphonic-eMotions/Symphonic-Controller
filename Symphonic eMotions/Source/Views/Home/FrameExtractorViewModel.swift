//
//  FrameExtractorViewModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/06/2023.
//

import SwiftUI

class FrameExtractorViewModel: FrameExtractorDelegate, ObservableObject {
    @Published var image: CIImage? = nil
    let frameExtractor: FrameExtractor
    
    init() {
        self.frameExtractor = FrameExtractor.shared
        self.frameExtractor.delegate = self
    }
    
    func captured(image: CIImage) {
        DispatchQueue.main.async {
            self.image = image
        }
    }
    
    func calculateAvgWhiteValue(_ image: CIImage) -> Double {
        // Convert image to grayscale
        let grayImage = image.applyingFilter(CIFilter.colorMonochrome().name , parameters: [
            kCIInputImageKey: image,
            kCIInputIntensityKey: 1.0,
            "inputColor": CIColor(red: 0.5, green: 0.5, blue: 0.5)
        ])
        // Calculate average white value
        if let cgImage = CIContext().createCGImage(grayImage, from: grayImage.extent) {
            return self.calculateAvgWhiteValue(cgImage)
        }
        return 0.0
    }
    
    private func calculateAvgWhiteValue(_ image: CGImage) -> Double {
        let pixelData = image.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var sum: UInt64 = 0
        let height = image.height
        let width = image.width
        let bytesPerRow = image.bytesPerRow
        
        for y in 0 ..< height {
            let i = y * bytesPerRow
            for x in 0 ..< width {
                let index = i + x * 4
                let pixel: UInt32 = UInt32(data[index])
                sum += UInt64(pixel)
            }
        }
        let totalPixels = width * height
        let avgValue = Double(sum) / Double(totalPixels)
        return avgValue
    }
}
