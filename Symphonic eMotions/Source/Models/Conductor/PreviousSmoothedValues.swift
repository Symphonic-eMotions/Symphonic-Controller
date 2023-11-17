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
        partIndex: String
    ) -> Double {
        
        // Get the previous smoothed value if it exists, otherwise use the current value
        let previousSmoothedValue = previousSmoothedValues[partIndex] ?? value
        
        // Determine whether we're ramping up or down
        let isIncreasing = value > previousSmoothedValue
        
        // Use rampUp alpha if the value is increasing, otherwise calculate logarithmic rampDown
        var alpha: Double
        if isIncreasing {
            alpha = (self.rampUp[partIndex] ?? 0) * 0.5 // Adjust the alpha value for ramp up if needed
        } else {
            // For ramp down, use a logarithmic scale - base it on the difference between the value and the previous value
            let rampDownValue = self.rampDown[partIndex] ?? 0
            let valueDifference = previousSmoothedValue - value
            alpha = log(valueDifference + 1) * rampDownValue // +1 to avoid log(0), adjust the multiplier (rampDownValue) as needed
        }
        
        // Calculate the dynamic floorValue based on alpha value
        let floorValueStart = 0.02
        let floorValueEnd = 0.3
        let dynamicFloorValue = floorValueStart + (floorValueEnd - floorValueStart) * alpha
        
        // Calculate the Exponential Moving Average (EMA)
        var smoothedValue = alpha * value + (1 - alpha) * previousSmoothedValue
        
        // Lower the floor of the values
        smoothedValue = max(smoothedValue - dynamicFloorValue, 0)
        
        // Calculate the dynamic boostFactor based on alpha value
        let boostFactorStart = 1.04
        let boostFactorEnd = 1.5    
        let dynamicBoostFactor = boostFactorStart + (boostFactorEnd - boostFactorStart) * alpha
        
        // Apply the dynamic boost factor
        smoothedValue *= dynamicBoostFactor
        
        // Clamp the value to the maximum of 1.0
        smoothedValue = min(smoothedValue, 1.0)
        
        // Store the current smoothed value for future use
        previousSmoothedValues[partIndex] = smoothedValue
        
        return smoothedValue
    }



    

    
    internal func valueLowPassFilter(
        value: Double,
        partIndex: String,
        cutoffFrequency: Double = 0.1,  // Adjust this to control the smoothing
        floorValue: Double = 0.1,
        boostFactor: Double = 1.1
    ) -> Double {
        
        // Get the previous filtered value if it exists, otherwise use the current value
        let previousFilteredValue = previousFilteredValues[partIndex] ?? value
        
        // Calculate the low-pass filter response
        // y[n] = y[n-1] + alpha * (x[n] - y[n-1])
        let alpha = cutoffFrequency / (cutoffFrequency + 1.0)
        var filteredValue = previousFilteredValue + alpha * (value - previousFilteredValue)
        
        // Lower the floor of the values
        filteredValue = max(filteredValue - floorValue, 0)
        
        // Apply an overall boost factor
        filteredValue = min(filteredValue * boostFactor, 1.0)
        
        // Store the current filtered value for future use
        previousFilteredValues[partIndex] = filteredValue
        
        return filteredValue
    }
    
}
