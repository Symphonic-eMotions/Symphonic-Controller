//
//  NoteSource.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import Foundation

enum NoteSource: String, Codable, CaseIterable {
    case midiFile
    case noteNumbers

    var description: String {
        switch self {
        case .midiFile:
            return "Midi File"
        case .noteNumbers:
            return "Note Numbers"
        }
    }
}
