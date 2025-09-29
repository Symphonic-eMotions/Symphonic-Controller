//
//  LevelProgressController.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 06/03/2024.
//

import Foundation

extension Conductor {
    func levelProgressForController(
        _ controllerLevels: [Int],
        currentLevel: Double
    ) -> Double {
        let currentIntLevel = Int(currentLevel)
        let nextLevelProgress = pow(currentLevel - Double(currentIntLevel), userSettings.levelProgressExponent)

        let isActiveInCurrentLevel = controllerLevels.contains(currentIntLevel)
        let isActiveInNextLevel = controllerLevels.contains(currentIntLevel + 1)

        // Level is on, stays on
        if isActiveInCurrentLevel && isActiveInNextLevel {
            return 1.0
        }
        // Level is off, next level is on so fade in with progress
        else if !isActiveInCurrentLevel && isActiveInNextLevel {
            return nextLevelProgress
        }
        // Level is on, next is off, so fade out with progress
        else if isActiveInCurrentLevel && !isActiveInNextLevel {
            return 1.0 - nextLevelProgress
        } else {
            return 0.0
        }
    }
}
