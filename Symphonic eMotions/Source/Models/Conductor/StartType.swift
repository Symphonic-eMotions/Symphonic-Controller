//
//  StartType.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import Foundation

enum StartType: String, Codable, CaseIterable, Equatable {
    case loopedTransport
    case loopedTrigger

    var description: String {
        switch self {
        // Midi file and Note numbers
        case .loopedTransport:
            return "Start with transport"
        // Midi file and Note numbers
        case .loopedTrigger:
            return "Start with movement"
        }
    }
}
