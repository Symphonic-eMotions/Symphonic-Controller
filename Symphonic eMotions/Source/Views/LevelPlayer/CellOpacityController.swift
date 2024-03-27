//
//  CellOpacityController.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/03/2024.
//

import SwiftUI
import Combine

class CellOpacityController: ObservableObject {
    
    @Published var opacities: [Double]
    private var timers: [Timer?] = []
    private var targetOpacities: [Double]
    private var currentMaxIndex: Int = -1
    private let riseDuration: TimeInterval
    private let fadeDuration: TimeInterval

    init(
        cellCount: Int,
        //TODO: riseDuration verhogen met de levels
        riseDuration: TimeInterval = 1.4,
        fadeDuration: TimeInterval = 0.8
    ) {
        self.opacities = Array(repeating: 0.0, count: cellCount)
        self.targetOpacities = Array(repeating: 1.0, count: cellCount)
        self.timers = Array(repeating: nil, count: cellCount)
        self.riseDuration = riseDuration
        self.fadeDuration = fadeDuration
    }
    
    func triggerEnvelope(forCell index: Int) {
        
        if index == -1 {
            // Als index -1 is, start het verlagen van de opacity van de huidige actieve cel.
            if currentMaxIndex >= 0 {
                startFadingCell(at: currentMaxIndex)
                currentMaxIndex = -1 // Reset de currentMaxIndex na het starten van de fade.
            }
            return // Stop de methode hier als index -1 is.
        }
        
        guard index >= 0 && index < opacities.count else { return }
        
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
    
    private func startFadingCell(at index: Int) {
        timers[index]?.invalidate() // Stop de huidige timer indien actief

        // Start een nieuwe timer die de opacity geleidelijk verlaagt
        timers[index] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.opacities[index] > 0 {
                self.opacities[index] -= 0.02 / self.fadeDuration // Verlaag de opacity geleidelijk
            } else {
                self.opacities[index] = 0 // Zorg ervoor dat de eindwaarde correct is
                timer.invalidate() // Stop de timer als de opacity 0 bereikt
            }
        }
    }
    
    private func resetOpacities(except index: Int) {
        for i in opacities.indices where i != index {
            // Oude timer stoppen
            timers[i]?.invalidate()

            // Start een nieuwe timer die de opacity geleidelijk verlaagt
            timers[i] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
                guard let self = self else { return }

                if self.opacities[i] > 0 {
                    self.opacities[i] -= 0.02 / self.fadeDuration // Verlaag de opacity geleidelijk
                } else {
                    self.opacities[i] = 0 // Zorg ervoor dat de eindwaarde correct is
                    timer.invalidate() // Stop de timer als de opacity 0 bereikt
                }
            }
        }
    }
}
