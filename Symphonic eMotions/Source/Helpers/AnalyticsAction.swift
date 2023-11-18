//
//  AnalyticsAction.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/11/2023.
//

import Foundation
import FirebaseAnalytics

enum AnalyticsAction: String {
    case onboardingA, onboardingB, onboardingC, onboardingD
    case onboardingVolume
    case onboardingLightning
    case logoShortCut
    case logoShortCutLong
    case trySet
    case sideBarNavigationProductLevel
    case sideBarNavigationProductLevelDisabled
    case sideBarNavigationSetLevel
    case sideBarNavigationSetLevelDisabled
    case loadSet
    case newVariation
    case startSet
    case stopSet
    case setEnded
    case nextSet
    case nextSetAutomated
    case holdLevel
    case endSet
    case instrumentCameraView
    case masterEfects
    case settings
    case settingsLong
    case sensitivity
    case distanceButtons
    case levelSpeed
    case setSpeed
    case instrumentEditor
    case setEditor
    case shareSet
    case addToPlaylist
    case appForeground
    case appBackground
    case unlockCreator

    var description: String {
        switch self {
            case .onboardingA: return "Onboarding Phase A"
            case .onboardingB: return "Onboarding Phase B"
            case .onboardingC: return "Onboarding Phase C"
            case .onboardingD: return "Onboarding Phase D"
            case .onboardingVolume: return "Onboarding volume settings"
            case .onboardingLightning: return "Onboarding lightning"
            case .logoShortCut: return "Logo Shortcut Activated"
            case .logoShortCutLong: return "Logo Long press Shortcut Activated"
            case .trySet: return "Trial Set Initiated"
            case .sideBarNavigationProductLevel: return "Sidebar Navigation product level"
            case .sideBarNavigationProductLevelDisabled: return "Sidebar Navigation product level disabled"
            case .sideBarNavigationSetLevel: return "Sidebar Navigation set level"
            case .sideBarNavigationSetLevelDisabled: return "Sidebar Navigation set level dsiabled"
            case .loadSet: return "Load Set"
            case .newVariation: return "New Set variation"
            case .startSet: return "Start Set"
            case .stopSet: return "Stop Set"
            case .setEnded: return "Set Ended"
            case .nextSet: return "Next Set requested"
            case .nextSetAutomated: return "Next Set automated"
            case .holdLevel: return "Hold Level"
            case .endSet: return "End of Set"
            case .instrumentCameraView: return "Instrument Camera View Accessed"
            case .masterEfects: return "Master Effects View Accessed"
            case .settings: return "Settings Accessed"
            case .settingsLong: return "Settings Long press Accessed"
            case .levelSpeed: return "Level Speed Changed"
            case .setSpeed: return "Set Speed Altered"
            case .sensitivity: return "Settings Sensitivity Blider"
            case .distanceButtons: return "Settings distance Buttons"
            case .instrumentEditor: return "Instrument Editor Used"
            case .setEditor: return "Set Editor Opened"
            case .shareSet: return "Set Shared"
            case .addToPlaylist: return "Added to Playlist"
            case .appForeground: return "App Entered Foreground"
            case .appBackground: return "App Entered Background"
            case .unlockCreator: return "Creator Content Unlocked"
        }
    }
    
    // Function within the enum to log this event
    func logEvent(sessionDisplay: SessionDisplay, fileGroup: FileGroup? = nil, setName: String? = nil) {
        var parameters: [String: NSObject] = [
            "action": self.description as NSObject,
            "sessionDisplay": sessionDisplay.title as NSObject
        ]
        
        if let fileGroup = fileGroup?.title {
            parameters["fileGroup"] = fileGroup as NSObject
        }
        
        if let setName = setName {
            parameters["setName"] = setName as NSObject
        }
        
        Analytics.logEvent("user_action", parameters: parameters)
    }
}
