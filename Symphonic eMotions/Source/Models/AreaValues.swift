//
//  AreaValues.swift
//  AreaValues
//
//  Created by Mihai Fratu on 31.07.2021.
//

import Foundation

struct AreaValues {
    
    let scaledValue: Double
    let previousScaledValue: Double
    let recentValues: [Double]
    let rawDifference: Int
    let maxValue: Int
    
    // Only return average on demand
    var average: Double {
        Double(recentValues.reduce(0.0, +)) / Double(recentValues.count)
    }
    
    func getAverage() -> Double {
        return self.average
    }
    
    func withNewRawValue(_ value: Int, maxValue: Int, feedback: Float) -> AreaValues {
        
        // How many frames do we look back
        let bufferLength: Int = 2
        
        // Calculate new scaledValue
        let newScaledValue =  Double(value) / Double(maxValue)
        
        // Calculate feedbackValue using newScaledValue
        let feedbackValue = min(newScaledValue + (Double(self.average) * Double(feedback)), 1.0)
        
        // Update recentValues with the new feedbackValue
        var recentValues = [feedbackValue] + self.recentValues
        if recentValues.count > bufferLength {
            recentValues = Array(recentValues[0..<bufferLength])
        }
        
        // Return a new instance of AreaValues with updated values, including previousScaledValue updated to the current scaledValue
        return AreaValues(scaledValue: feedbackValue,
                          previousScaledValue: self.scaledValue,
                          recentValues: recentValues,
                          rawDifference: rawDifference,
                          maxValue: maxValue)
    }
}

extension AreaValues {
    init(value: Int, maxValue: Int) {
        let initialScaledValue = Double(value) / Double(maxValue)
        self.scaledValue = initialScaledValue
        self.previousScaledValue = initialScaledValue
        self.recentValues = [Double(value)]
        self.rawDifference = value
        self.maxValue = maxValue
    }
}

struct DoubleValues {
    
    let scaledValue: Double
    let recentValues: [Double]
    let rawDifference: Int
    let maxValue: Int
    
    //Only return average on demand
    var average: Double { Double(recentValues.reduce(0.0, +)) / Double(recentValues.count) }
    
    func getAverage() -> Double{
        return self.average
    }
}

extension DoubleValues {
    init(value: Int, maxValue: Int) {
        self.scaledValue = Double(value) / Double(maxValue)
        self.recentValues = [Double(value)]
        self.rawDifference = value
        self.maxValue = maxValue
    }
}
