//
//  Length.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/05/2024.
//

import Foundation

enum Length: String, CaseIterable, Codable {
    case fourWhole = "4 maten"
    case threeWhole = "3 maten"
    case twoWhole = "2 maten"
    case whole = "1 maat"
    case half = "halve maat"
    case quarter = "1 tel"
    case eighth = "achtste"
    case sixteenth = "zestiende"

    var duration: Float32 {
        switch self {
        case .fourWhole:
            return 16.0
        case .threeWhole:
            return 12.0
        case .twoWhole:
            return 8.0
        case .whole:
            return 4.0
        case .half:
            return 2.0
        case .quarter:
            return 1.0
        case .eighth:
            return 0.5
        case .sixteenth:
            return 0.25
        }
    }

    var maxStrum: Double {
        // maximum strum is 95% of the note length
        return Double(duration) * 0.95
    }
}
