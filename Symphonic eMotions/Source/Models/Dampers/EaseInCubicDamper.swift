//
//  EaseInCubicDamper.swift
//  eMotion
//
//  Created by Mihai Fratu on 01.10.2021.
//

import Foundation

struct EaseInCubicDamper: Damper {
    
    func damp(value: Double) -> Double { value * value * value }
}
