//
//  ColumnOpacityController.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 10/04/2024.
//

import Combine

// Subclass voor het aansturen van kolomopaciteiten
import Foundation

class ColumnOpacityController: OpacityController {
    override func triggerEnvelope(forIndex columnIndex: Int) {
        if columnIndex == -1 {
            // Als columnIndex -1 is, start het verlagen van de opaciteit van de huidige actieve kolom.
            if currentMaxIndex >= 0 {
                startFading(at: currentMaxIndex)
                currentMaxIndex = -1 // Reset de currentMaxIndex na het starten van de fade.
            }
            return // Stop de methode hier als columnIndex -1 is.
        }

        guard columnIndex >= 0, columnIndex < opacities.count else { return }

        if columnIndex == currentMaxIndex { return } // Als de trigger voor dezelfde kolom is, doe dan niets

        resetOpacities(except: columnIndex) // Reset opacities voor alle andere kolommen
        currentMaxIndex = columnIndex // Update de huidigeMaxIndex

        timers[columnIndex]?.invalidate() // Stop de huidige timer indien actief
        targetOpacities[columnIndex] = 1.0 // Stel het doel van de opacity in op 1.0

        // Start een nieuwe timer die de opacity geleidelijk verhoogt
        timers[columnIndex] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.opacities[columnIndex] < self.targetOpacities[columnIndex] {
                self.opacities[columnIndex] += 0.02 / self.riseDuration // Verhoog de opacity geleidelijk
            } else {
                self.opacities[columnIndex] = self.targetOpacities[columnIndex] // Zorg ervoor dat de eindwaarde correct is
                timer.invalidate() // Stop de timer als we het doel bereiken
            }
        }
    }
}
