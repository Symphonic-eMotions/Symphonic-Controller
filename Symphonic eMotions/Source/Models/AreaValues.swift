//
//  AreaValues.swift
//  AreaValues
//
//  Created by Mihai Fratu on 31.07.2021.
//

import Foundation

struct AreaValues {
    
    let scaledValue: Double
    let recentValues: [Double]
    let rawDifference: Int
    let maxValue: Int
    
    //Only return average on demand
    var average: Double { Double(recentValues.reduce(0.0, +)) / Double(recentValues.count) }
    
    func withNewRawValue(_ value: Int, maxValue: Int, feedback: Float) -> AreaValues {
        
//        print("Engine: maxValue: \(maxValue) feedback: \(feedback)")
        
        //Hoeveel frames kijk average terug
        let bufferLength: Int = 2
        
        //
        
        let scaledValue =  Double(value) / Double(maxValue)

        let feedbackValue = min(scaledValue + (Double(self.average) * Double(feedback)), 1.0)
        
        var recentValues = [feedbackValue] + self.recentValues
        
        if recentValues.count > bufferLength {
            recentValues = Array(recentValues[0..<bufferLength])
        }
        
        return AreaValues(scaledValue: feedbackValue,
                          recentValues: recentValues,
                          rawDifference: rawDifference,
                          maxValue: maxValue)
    }
}

extension AreaValues {
    init(value: Int, maxValue: Int) {
        self.scaledValue = Double(value) / Double(maxValue)
        self.recentValues = [Double(value)]
        self.rawDifference = value
        self.maxValue = maxValue
    }
}
