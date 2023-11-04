//
//  PreviousSmoothedValues.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 04/11/2023.
//

import Foundation

extension Conductor {
    
    internal func valueSmoother(
        value: Double,
        partIndex: String,
        floorValue: Double = 0.01,
        boostFactor: Double = 1.05
    ) -> Double {
        
        // Get the previous smoothed value if it exists, otherwise use the current value
        let previousSmoothedValue = previousSmoothedValues[partIndex] ?? value
        
        // Determine whether the value is increasing or decreasing
        let isIncreasing = value > previousSmoothedValue
        
        // Choose the appropriate alpha based on the direction
        let alpha = isIncreasing ? self.rampUp[partIndex]! : self.rampDown[partIndex]!
        
        // Calculate the Exponential Moving Average (EMA)
        var smoothedValue = alpha * value + (1 - alpha) * previousSmoothedValue
        
        // Lower the floor of the values
        smoothedValue = max(smoothedValue - floorValue, 0)
        
        // Apply an overall boost factor
        smoothedValue = min(smoothedValue * boostFactor, 1.0)
        
        // Store the current smoothed value for future use
        previousSmoothedValues[partIndex] = smoothedValue
        
        return smoothedValue
    }
    
}
