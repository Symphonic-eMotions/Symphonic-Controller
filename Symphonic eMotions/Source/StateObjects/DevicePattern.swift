//
//  DevicePattern.swift
//  Symphonic Controller
//
//  Created by Frans-Jan Wind on 15/10/2024.
//

import Foundation

enum DevicePattern: String, CaseIterable {
    case stap0 = "/off"
    case stap1 = "/stap1"
    case stap2 = "/stap2"
    case stap3 = "/stap3"
    case stap4 = "/stap4"
    case stap5 = "/stap5"
    case stap6 = "/stap6"
    case stap7 = "/stap7"
    case stap8 = "/stap8"
    case stap9 = "/stap9"
    case stap10 = "/stap10"
    case stap11 = "/stap11"
    
    // Failable initializer om te initialiseren vanuit een string
    init?(pattern: String) {
        self.init(rawValue: pattern)
    }
    
    // Computed property voor de knoptekst
        var displayName: String {
            switch self {
            case .stap0:
                return "Uit"
            case .stap1:
                return "1 Baarmoeder"
            case .stap2:
                return "2 Baby huilen"
            case .stap3:
                return "3 School"
            case .stap4:
                return "4 Feest"
            case .stap5:
                return "5 Kantoor"
            case .stap6:
                return "6 Schreeuwen"
            case .stap7:
                return "7 Regen"
            case .stap8:
                return "8 ..."
            case .stap9:
                return "9 Alles"
            case .stap10:
                return "10 Oceaan +"
            case .stap11:
                return "11 Bijna alles"
            }
        }
}
