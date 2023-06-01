//
//  NotesSequenceType.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/06/2023.
//

import Foundation

enum NotesSequenceType: String, Codable, CaseIterable {
    
    case firstNote
    case nextForward
    case nextBackward
    case randomNote
    
    var description: String {
        switch self{
        case .firstNote:
            return "Only first note"
        case .nextForward:
            return "Next forward"
        case .nextBackward:
            return "Next backward"
        case .randomNote:
            return "Random note"
        }
    }
}
