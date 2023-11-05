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
        
        // Use rampUp as the alpha for both increasing and decreasing values
        let alpha = self.rampUp[partIndex]!
        
        // Use rampDown as the feedback factor for the previous value
        let feedback = self.rampDown[partIndex]!
        
        // Calculate the smoothed value considering the feedback
        var smoothedValue = alpha * value + (1 - alpha) * (previousSmoothedValue * feedback + value * (1 - feedback))
        
        //MARK: Normalizing
        // Lower the floor of the values
        smoothedValue = max(smoothedValue - floorValue, 0)
        
        // Apply an overall boost factor
        smoothedValue = min(smoothedValue * boostFactor, 1.0)
        
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
