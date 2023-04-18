//
//  StartTypes.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import Foundation

enum StartType: String, Codable {
    
    case loopedTransport
    case loopedTrigger
    case oneShot
    
    var description: String {
        switch self {
        //Midi file and Note numbers
        case .loopedTransport:
            return "Start and stop track with transport"
        //Midi file and Note numbers
        case .loopedTrigger:
            return "Start and stop track with movement wave"
        //Note numbers
        case .oneShot:
            return  "Play single note"
        }
    }
}
