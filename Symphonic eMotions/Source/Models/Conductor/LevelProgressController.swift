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
        exponent: Double = 3.0
    ) -> Double {
        let currentIntLevel = Int(currentLevel)
        let nextLevelProgress = pow(currentLevel - Double(currentIntLevel), exponent)

        let isActiveInCurrentLevel = controllerLevels.contains(currentIntLevel)
        let isActiveInNextLevel = controllerLevels.contains(currentIntLevel + 1)
//        let isActiveInLevelAfterNext = controllerLevels.contains(currentIntLevel + 2)

        // Als de controller actief is in de huidige level en ook in de volgende level, blijf vol activeren
        if isActiveInCurrentLevel {
            return 1.0
        }
        // Als de controller nu niet actief is, maar wel in de volgende level wordt geactiveerd
        else if !isActiveInCurrentLevel && isActiveInNextLevel {
            // Begin met activeren op basis van de voortgang naar de volgende level
            return nextLevelProgress
        }
        // Als de controller nu actief is, maar in de volgende level niet meer actief is
        else if isActiveInCurrentLevel && !isActiveInNextLevel {
            // Deactiveer geleidelijk aan, gebaseerd op de voortgang naar de volgende level
            // Dit zorgt ervoor dat de controller langzaam uitfaseert in plaats van abrupt stopt
            return 1.0 - nextLevelProgress
        }
        // Als de controller nu niet actief is, niet actief in de volgende level, maar weer actief in de level daarna
//        else if !isActiveInCurrentLevel && !isActiveInNextLevel && isActiveInLevelAfterNext {
//            // In dit scenario blijft de controller uitgeschakeld, maar je zou kunnen anticiperen op de volgende activering
//            // Afhankelijk van je specifieke wensen kan je hier logica toevoegen om vooruit te lopen op de volgende activering
//            // Voor nu houden we de controller uitgeschakeld
//            return 0.0
//        }
        else {
            return 0.0
        }
    }
    
    internal func levelProgressForControllerBackup(
        _ controllerLevels: [Int],
        currentLevel: Double,
        exponent: Double = 3.0
    ) -> Double {
        let currentIntLevel = Int(currentLevel)
        let nextLevelProgress = pow(currentLevel - Double(currentIntLevel), exponent)

        let isActiveInCurrentLevel = controllerLevels.contains(currentIntLevel)
        let isActiveInNextLevel = controllerLevels.contains(currentIntLevel + 1)
        let isActiveInLevelAfterNext = controllerLevels.contains(currentIntLevel + 2)

        // Als de controller actief is in de huidige level en ook in de volgende level, blijf vol activeren
        if isActiveInCurrentLevel && isActiveInNextLevel {
            return 1.0
        }
        // Als de controller nu niet actief is, maar wel in de volgende level wordt geactiveerd
        else if !isActiveInCurrentLevel && isActiveInNextLevel {
            // Begin met activeren op basis van de voortgang naar de volgende level
            return nextLevelProgress
        }
        // Als de controller nu actief is, maar in de volgende level niet meer actief is
        else if isActiveInCurrentLevel && !isActiveInNextLevel {
            // Deactiveer geleidelijk aan, gebaseerd op de voortgang naar de volgende level
            // Dit zorgt ervoor dat de controller langzaam uitfaseert in plaats van abrupt stopt
            return 1.0 - nextLevelProgress
        }
        // Als de controller nu niet actief is, niet actief in de volgende level, maar weer actief in de level daarna
        else if !isActiveInCurrentLevel && !isActiveInNextLevel && isActiveInLevelAfterNext {
            // In dit scenario blijft de controller uitgeschakeld, maar je zou kunnen anticiperen op de volgende activering
            // Afhankelijk van je specifieke wensen kan je hier logica toevoegen om vooruit te lopen op de volgende activering
            // Voor nu houden we de controller uitgeschakeld
            return 0.0
        }

        // Als geen van bovenstaande condities waar is, is de controller niet actief
        return 0.0
    }

}
