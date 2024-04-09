//
//  OpacityController.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 09/04/2024.
//

import SwiftUI
import Combine

// Basisclass die gemeenschappelijke logica bevat
class OpacityController: ObservableObject {
    @Published var opacities: [Double]
    internal var timers: [Timer?] = []
    internal var targetOpacities: [Double]
    internal var currentMaxIndex: Int = -1
    internal let riseDuration: TimeInterval
    internal let fadeDuration: TimeInterval

    init(count: Int, riseDuration: TimeInterval = 1.4, fadeDuration: TimeInterval = 0.8) {
        self.opacities = Array(repeating: 0.0, count: count)
        self.targetOpacities = Array(repeating: 1.0, count: count)
        self.timers = Array(repeating: nil, count: count)
        self.riseDuration = riseDuration
        self.fadeDuration = fadeDuration
    }

    func triggerEnvelope(forIndex index: Int) {
        //Override in sub-class
    }

    func startFading(at index: Int) {
        timers[index]?.invalidate()

        timers[index] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.opacities[index] > 0 {
                self.opacities[index] -= 0.02 / self.fadeDuration
            } else {
                self.opacities[index] = 0
                timer.invalidate()
            }
        }
    }

    func resetOpacities(except index: Int) {
        for i in opacities.indices where i != index {
            timers[i]?.invalidate()
            
            timers[i] = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                
                if self.opacities[i] > 0 {
                    self.opacities[i] -= 0.02 / self.fadeDuration
                } else {
                    self.opacities[i] = 0
                    timer.invalidate()
                }
            }
        }
    }
}

