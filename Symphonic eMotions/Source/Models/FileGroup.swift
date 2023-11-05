//
//  FileGroup.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 02/06/2023.
//
// Used to group files in navigation

import Foundation

enum FileGroup: Hashable, Codable {
    
    //Template is used as ID for Creator mode
    case template
    
    //The try it out lay out
    case home
    //not yet used
    case demo
    //Pro sets
    case pro
    case art
    case none
    
    //Extra features as applaus
    case playlists
    
    var title: String {
        switch self {
        case .template:
            return "Template"
        case .home:
            return "Home"
        case .demo:
            return "Demo"
        case .pro:
            return "Pro"
        case .art:
            return "Art"
        case .playlists:
            return "Playlists"
        case .none:
            return "None"
        }
    }
}
