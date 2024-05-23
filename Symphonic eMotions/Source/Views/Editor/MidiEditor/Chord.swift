//
//  Chord.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/05/2024.
//

import Foundation

enum Chord: String, CaseIterable, Codable {
    case C, G, Am, Em, F, Dm, Bm, D, A, E, Fm, Cm

    var notes: [UInt8] {
        switch self {
        case .C: return [48, 52, 55]
        case .G: return [43, 47, 50]
        case .Am: return [45, 48, 52]
        case .Em: return [40, 43, 47]
        case .F: return [41, 45, 48]
        case .Dm: return [38, 41, 45]
        case .Bm: return [47, 50, 54]
        case .D: return [38, 42, 45]
        case .A: return [33, 37, 40]
        case .E: return [40, 44, 47]
        case .Fm: return [41, 44, 48]
        case .Cm: return [48, 51, 55]
        }
    }
}
