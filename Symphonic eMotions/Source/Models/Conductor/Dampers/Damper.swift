//
//  Damper.swift
//  eMotion
//
//  Created by Mihai Fratu on 01.10.2021.
//

import Foundation

protocol Damper {
    func damp(value: Double) -> Double
}
