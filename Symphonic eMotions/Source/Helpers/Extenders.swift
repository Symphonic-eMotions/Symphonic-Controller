//
//  Extenders.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 29/03/2023.
//

import Foundation

extension URL {
    init(_ string: String) {
        self.init(string: "\(string)")!
    }
}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

extension Double {
    func scaled(outputStart: Double, outputEnd: Double, inputStart: Double = 0.0, inputEnd: Double = 1.0) -> Double {
        guard inputStart != inputEnd else {
            print("Error: inputStart and inputEnd cannot be the same.")
            return 0.0
        }
        return outputStart + ((outputEnd - outputStart) * (self - inputStart) / (inputEnd - inputStart))
    }
}

extension Double {
    func transform(
        outputStart: Double,
        outputEnd: Double,
        inputStart: Double = 0.0,
        inputEnd: Double = 1.0,
        transformationDegree: Double
        
    ) -> Double {
        guard inputStart != inputEnd else {
            print("Error: inputStart and inputEnd cannot be the same.")
            return 0.0
        }
        
        let normalizedValue = (self - inputStart) / (inputEnd - inputStart)
        
        if transformationDegree > 0 {
            // Exponential transformation
            let expTransform = pow(normalizedValue, transformationDegree)
            return outputStart + (outputEnd - outputStart) * expTransform
        } else if transformationDegree < 0 {
            // Logarithmic transformation
            let absDegree = abs(transformationDegree)
            // Avoiding log of 0, adjust normalized value to be strictly > 0 for log calculation
            let adjustedValue = max(normalizedValue, 0.00001)
            let logTransform = log(adjustedValue) / log(absDegree)
            return outputStart + (outputEnd - outputStart) * logTransform
        } else {
            // Linear transformation as fallback for degree == 0
            return outputStart + (outputEnd - outputStart) * normalizedValue
        }
    }
}
