//
//  FileGroup.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 02/06/2023.
//

import Foundation

enum FileGroup: Hashable, Codable {
    
    case template
    case home
    case demo
    case pro
    case art
    case none
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
