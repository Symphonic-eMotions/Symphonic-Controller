//
//  DevicePattern.swift
//  Symphonic Controller
//
//  Created by Frans-Jan Wind on 15/10/2024.
//

import Foundation

enum DevicePattern: String, CaseIterable {
    case stap1 = "/stap1"
    case stap2 = "/stap2"
    case stap3 = "/stap3"
    case stap4 = "/stap4"
    case stap5 = "/stap5"
    case stap6 = "/stap6"
    case stap7 = "/stap7"
    case stap8 = "/stap8"
    case stap9 = "/stap9"
    
    // Failable initializer om te initialiseren vanuit een string
    init?(pattern: String) {
        self.init(rawValue: pattern)
    }
}
