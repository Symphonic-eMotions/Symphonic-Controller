//
//  EaseOutCubicDamper.swift
//  eMotion
//
//  Created by Frans-Jan Wind 30.05.2022
//

import Foundation

struct EaseOutCubicDamper: Damper {
    // expr ($f1-1)*($f1-1)*($f1-1)+1
    func damp(value: Double) -> Double { (value - 1) * (value - 1) * (value - 1) + 1 }
}
