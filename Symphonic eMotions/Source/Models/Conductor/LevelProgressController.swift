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
        currentLevel: Double,
        exponent: Double = 3.0,
        difficulty: Double = 0.0 // Waarde tussen 0 en 1
    ) -> Double {
        let currentIntLevel = Int(currentLevel)
        let nextLevelProgress = pow(currentLevel - Double(currentIntLevel), exponent)
        
        // Bereken de factor voor terugloopsnelheid gebaseerd op difficulty
        //backSpeedFactor=5.0+(0.1−5.0)×difficulty
        let backSpeedFactor = 5.0 - 4.9 * difficulty

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
        
        if isActiveInCurrentLevel && isActiveInNextLevel {
            return 1.0
        }
        else if !isActiveInCurrentLevel && isActiveInNextLevel {
            return nextLevelProgress
        }
        else if isActiveInCurrentLevel && !isActiveInNextLevel {
            // Pas de terugloopsnelheid aan met backSpeedFactor
            return 1.0 - (nextLevelProgress * backSpeedFactor)
        }
        else {
            return 0.0
        }
    }
}
