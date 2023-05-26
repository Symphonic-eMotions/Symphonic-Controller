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
    
    case demo
    case pro
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
    
    var title: String {
        switch self {
        case .demo:
            return "Demo"
        case .pro:
            return "Pro"
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
        }
    }
}
