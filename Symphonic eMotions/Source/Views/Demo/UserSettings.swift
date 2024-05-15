//
//  UserSettings.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import Foundation
import SwiftUI

enum UserCode: String {
    case none
    case creator
}

class UserSettings: ObservableObject {
    
    static let shared = UserSettings()

    static let currentSettingsVersion = AppUtils.semVersionString()

    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    @AppStorage(UserDefaultsKeys.isCapturingRunning) var isCapturingRunning: Bool = false
    
    @AppStorage(UserDefaultsKeys.levelProgressExponent) var levelProgressExponent: Double = 2.5
    
    @AppStorage(UserDefaultsKeys.videoFeedback) var videoFeedback: Double = 0.5
    @AppStorage(UserDefaultsKeys.sensitivitySession) var sensitivitySession: Double = 0.8
    @AppStorage(UserDefaultsKeys.sensitivityDeviation) var sensitivityDeviation: Double = 0
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introductie.json"
    @AppStorage(UserDefaultsKeys.showPartEditor) var showPartEditor: Bool = false
    
    //Have a observed van for states
    @Published var userCode: UserCode {
        didSet {
            //Persist to UserDefaults for re use after restart app
            UserDefaults.standard.set(userCode.rawValue, forKey: "userCode")
        }
    }

    init() {
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.appVersion) != UserSettings.currentSettingsVersion {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isSetPlaying)
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isCapturingRunning)
            UserDefaults.standard.set(2.5, forKey: UserDefaultsKeys.levelProgressExponent)
            UserDefaults.standard.set(0.5, forKey: UserDefaultsKeys.videoFeedback)
            UserDefaults.standard.set(0.8, forKey: UserDefaultsKeys.sensitivitySession)
            UserDefaults.standard.set(0, forKey: UserDefaultsKeys.sensitivityDeviation)
            UserDefaults.standard.set("Introductie.json", forKey: UserDefaultsKeys.currentUrl)
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.showPartEditor)
            UserDefaults.standard.set(UserSettings.currentSettingsVersion, forKey: UserDefaultsKeys.appVersion)
        }

        //Regel opslag van ingevoerde user code
        if let rawValue = UserDefaults.standard.string(forKey: "userCode"),
           let initialCode = UserCode(rawValue: rawValue) {
            self.userCode = initialCode
        } else {
            self.userCode = .none
        }
    }
}

struct UserDefaultsKeys {
    
    static let appVersion = "appVersion"
    
    static let isSetPlaying = "isSetPlaying"
    static let isCapturingRunning = "isCapturingRunning"
    
//    static let levelSpeed = "levelSpeed"
    static let levelProgressExponent = "levelProgressExponent"
//    static let levelDifficulty = "levelDifficulty"
    
    static let videoFeedback = "videoFeedback"
    static let sensitivitySession = "sensitivitySession"
    static let sensitivityDeviation = "sensitivityDeviation"
    
    static let currentUrl = "currentUrl"
    static let showPartEditor = "showPartEditor"
    
    static let persistance = "persistance"
    static let tempo = "tempo"
}
