//
//  EaseInOutCubicDamper.swift
//  eMotion
//
//  Created by Mihai Fratu on 01.10.2021.
//

import Foundation

struct EaseInOutCubicDamper: Damper {
//    func damp(value: Double) -> Double {
//        value < 0.5 ? 4 * value * value * value : 1 - pow(-2 * value + 2, 3) / 2
//    }

    func damp(value: Double) -> Double {
        if value < 0.5 {
            return 4 * value * value * value
        } else {
            let f = ((2 * value) - 2)
            return 0.5 * f * f * f + 1
        }
    }
}
