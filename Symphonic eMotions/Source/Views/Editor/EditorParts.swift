//
//  EditorParts.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 15/06/2023.
//

import Foundation

enum EditorParts: String, CaseIterable {
    case none
    case set
    case levels
    case source
    case start
    case variation
    case location
    //Lets be compatible with 16 tracks
    case track0
    case track1
    case track2
    case track3
    case track4
    case track5
    case track6
    case track7
    case track8
    case track9
    case track10
    case track11
    case track12
    case track13
    case track14
    case track15
    
    var title: String {
        switch self {
        case .none:
            return ""
        case .set:
            return "Set"
        case .levels:
            return "Levels"
        case .source:
            return "Note source"
        case .start:
            return "Start type"
        case .variation:
            return "Variation type"
        case .location:
            return "Position in camera view"
        default:
            return "Track"
        }
    }
}
