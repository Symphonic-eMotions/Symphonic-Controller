//
//  TimeBasedEnvelope.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 26/02/2024.
//

import Foundation

class TimeBasedEnvelope {
    
    var currentValue: Double = 0.0 // Startwaarde van de envelope
    var lastUpdateTime: DispatchTime = DispatchTime.now()
    var accumulatedTime: Double = 0.0 // Accumulator voor de tijd
    
    // Functie om de envelope bij te werken op basis van beweging
    func updateEnvelope(
        withMovement movement: Double,
        previousMovement: Double,
        decreaseRate: Double,
        increaseRate: Double
    ) -> Double {
        let now = DispatchTime.now()
        let timeElapsed = Double(now.uptimeNanoseconds - lastUpdateTime.uptimeNanoseconds) / 1_000_000_000 // Tijd in seconden

        // Voeg de verstreken tijd toe aan de accumulator
        accumulatedTime += timeElapsed
        
        //We update the envelope not as much as the frame rate
        if accumulatedTime >= 0.01 {
            
            if movement >= previousMovement && movement > 0.1 {
                currentValue += increaseRate
                accumulatedTime = 0 // Reset de accumulator
            } else {
                currentValue -= decreaseRate
                accumulatedTime = 0
                
            }
        }
        
        //Noramilze output
        currentValue = min(max(currentValue, 0), 1)
        
        
        // Update time for next compare
        lastUpdateTime = now
        
        return currentValue
    }
}

