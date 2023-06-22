//
//  SessionDisplay.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 21/10/2022.
//

import Foundation
import SwiftUI

//SessionDisplay is used for navigating the SwiftUI view
//For the editor this same enum is used for SessionDisplaySub navigation
enum SessionDisplay: Hashable, Codable {
    
    case home
    case demo
    case pro
    case creator
    case countDown
    case playlists
    case swiftUI
    case setInfo
    case spriteKit
    case editor
    case setEditor
    case playListEditor
    case calibrator
    case none
    case page01
    case page02
    case page03
    case page04
    case page05
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .demo:
            return "Demo"
        case .pro:
            return "Pro"
        case .creator:
            return "Creator"
        case .countDown:
            return "Count Down"
        case .playlists:
            return "Playlists"
        case .swiftUI:
            return "Grid View"
        case .spriteKit:
            return "Game Skin"
        case .setInfo:
            return "Set information"
        case .editor:
            return "Editor from saved sets"
        case .playListEditor:
            return "Editor from playlist"
        case .setEditor:
            return "Set editor"
        case .calibrator:
            return "Kalibrator!"
        case .none:
            return "Nothing"
        case .page01:
            return "Introduction sheet 1"
        case .page02:
            return "Introduction sheet 2"
        case .page03:
            return "Introduction sheet 3"
        case .page04:
            return "Introduction sheet 4"
        case .page05:
            return "Introduction sheet 5"
        }
    }
}
