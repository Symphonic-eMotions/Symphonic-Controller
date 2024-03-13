//
//  LevelProgressController.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 06/03/2024.
//

import Foundation

extension Conductor {
    
    internal func levelProgressForController(
        _ controllerLevels: [Int],
        currentLevel: Double
//        ,
//        exponent: Double = 2.5,
//        difficulty: Double = 0.0 // Waarde tussen 0 en 1
    ) -> Double {
        
        //Debug var
        var lastRounded: Double? = nil
        //Debug func
        func printRounded(newValue: Double, tag: String) {
            // Rond af op 1 decimaal
            let roundedValue = round(newValue * 10) / 10
            
            // Controleer of de afgeronde waarde verschilt van de laatst geprinte waarde
            if roundedValue != lastRounded {
                print("\(tag): \(roundedValue)")
                // Update de laatst geprinte waarde
                lastRounded = roundedValue
            }
        }
        
        let currentIntLevel = Int(currentLevel)
        let nextLevelProgress = pow(currentLevel - Double(currentIntLevel), userSettings.levelProgressExponent)
        
        // Bereken de factor voor terugloopsnelheid gebaseerd op difficulty
        //backSpeedFactor=5.0+(0.1−5.0)×difficulty
        let backSpeedFactor = 5.0 - 4.9 * userSettings.levelDifficulty
        
        // Bij difficulty 0 is de factor 2 (twee keer zo lang)
        // Bij difficulty 1 is de factor 0.5 (twee keer zo kort)
//        let backSpeedFactor = 1.5 - difficulty // Lineaire interpolatie van 2 naar 0.5
        
        //MARK: Alternatieven
//        let backSpeedFactor = pow(2.0, 1 - difficulty) // Exponentiële afname van 2 naar 1
//        let backSpeedFactor = 1 / (log(difficulty + 1) + 1) // Logaritmische afname
//        let backSpeedFactor = 1.5 - (difficulty * difficulty) // Quadratische aanpassing
//        let backSpeedFactor = difficulty < 0.5 ? 2.0 - difficulty : 0.75 - (difficulty - 0.5) * 0.5
//        let backSpeedFactor = 1.25 + sin(difficulty * π / 2) * 0.75

        
        let isActiveInCurrentLevel = controllerLevels.contains(currentIntLevel)
        let isActiveInNextLevel = controllerLevels.contains(currentIntLevel + 1)
        
        //Level is on, stays on
        if isActiveInCurrentLevel && isActiveInNextLevel {
            return 1.0
        }
        //Level is off, next level is on ()
        else if !isActiveInCurrentLevel && isActiveInNextLevel {
            return nextLevelProgress
        }
        
        else if isActiveInCurrentLevel && !isActiveInNextLevel {
            return 1.0 - (nextLevelProgress * backSpeedFactor)
        }
        else {
            return 0.0
        }
    }
}
