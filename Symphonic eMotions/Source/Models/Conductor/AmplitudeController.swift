//
//  AmplitudeController.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 28/02/2024.
//

import Foundation

class AmplitudeController {
    var currentAmplitude: Double = 0.0
    var targetAmplitude: Double = 0.0
    var stepSize: Double = 0.01 // Hoe snel de amplitude verandert per update

    // Methode om de amplitude te updaten richting de doelamplitude
    func updateAmplitude() {
        if currentAmplitude < targetAmplitude {
            currentAmplitude = min(currentAmplitude + stepSize, targetAmplitude)
        } else if currentAmplitude > targetAmplitude {
            currentAmplitude = max(currentAmplitude - stepSize, targetAmplitude)
        }
        // Pas hier de amplitude van het audiosignaal aan met 'currentAmplitude'
    }

    // Methode om een nieuwe doelamplitude in te stellen
    func setTargetAmplitude(_ newTarget: Double) {
        targetAmplitude = min(max(newTarget, 0.0), 1.0) // Zorg ervoor dat de waarde tussen 0 en 1 blijft
    }
}
