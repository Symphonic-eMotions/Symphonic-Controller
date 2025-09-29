//
//  CellOpacityController.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 09/04/2024.
//

import Combine

// Subclass voor het aansturen van celopaciteiten
import Foundation

class CellOpacityController: OpacityController {
    override func triggerEnvelope(forIndex index: Int) {
        if index == -1 {
            // Als index -1 is, start het verlagen van de opacity van de huidige actieve cel.
            if currentMaxIndex >= 0 {
                startFading(at: currentMaxIndex)
                currentMaxIndex = -1 // Reset de currentMaxIndex na het starten van de fade.
            }
            return // Stop de methode hier als index -1 is.
        }

        guard index >= 0, index < opacities.count else { return }

        if index == currentMaxIndex { return } // Als de trigger voor dezelfde cel is, doe dan niets

        resetOpacities(except: index) // Reset opacities voor alle andere cellen
        currentMaxIndex = index // Update de huidigeMaxIndex

        timers[index]?.invalidate() // Stop de huidige timer indien actief
        targetOpacities[index] = 1.0 // Stel het doel van de opacity in op 1.0

        // Start een nieuwe timer die de opacity geleidelijk verhoogt
        timers[index] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.opacities[index] < self.targetOpacities[index] {
                self.opacities[index] += 0.02 / self.riseDuration // Verhoog de opacity geleidelijk
            } else {
                self.opacities[index] = self.targetOpacities[index] // Zorg ervoor dat de eindwaarde correct is
                timer.invalidate() // Stop de timer als we het doel bereiken
            }
        }
    }
}
