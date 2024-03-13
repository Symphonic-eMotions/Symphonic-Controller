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
    
    @AppStorage(UserDefaultsKeys.levelProgressExponent) var levelProgressExponent: Double = 2.5
    @AppStorage(UserDefaultsKeys.levelDifficulty) var levelDifficulty: Double = 0.67
    
    @AppStorage(UserDefaultsKeys.videoFeedback) var videoFeedback: Double = 0.5
    @AppStorage(UserDefaultsKeys.sensitivitySession) var sensitivitySession: Double = 0.8
    @AppStorage(UserDefaultsKeys.sensitivityDeviation) var sensitivityDeviation: Double = 0
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introductie.json"
    @AppStorage(UserDefaultsKeys.showPartEditor) var showPartEditor: Bool = false
    
    private var _levelSpeed: Double = UserDefaults.standard.double(forKey: UserDefaultsKeys.levelSpeed) {
        didSet {
            if _levelSpeed < 0.01 {
                _levelSpeed = 0.01
            }
            UserDefaults.standard.set(_levelSpeed, forKey: UserDefaultsKeys.levelSpeed)
        }
    }
    
    var levelSpeed: Double {
        get { _levelSpeed }
        set { _levelSpeed = newValue }
    }
    
    var levelSpeedBinding: Binding<Double> {
        Binding<Double>(
            get: { self.levelSpeed },
            set: { self.levelSpeed = $0 }
        )
    }
    
    //Have a observed van for states
    @Published var userCode: UserCode {
        didSet {
            //Persist to UserDefaults for re use after restart app
            UserDefaults.standard.set(userCode.rawValue, forKey: "userCode")
        }
    }

    init() {
                    
        let savedVersion = UserDefaults.standard.string(forKey: UserDefaultsKeys.appVersion) ?? "0.0"
        if savedVersion != UserSettings.currentSettingsVersion {
//            resetToDefaultSettings()
            UserDefaults.standard.set(UserSettings.currentSettingsVersion, forKey: UserDefaultsKeys.appVersion)
        }
        
        //Default value for levelSpeed
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.levelSpeed) == nil {
                    _levelSpeed = 1
                }
        
        if let rawValue = UserDefaults.standard.string(forKey: "userCode"),
           let initialCode = UserCode(rawValue: rawValue) {
            self.userCode = initialCode
        } else {
            self.userCode = .none
        }
    }
    
    func resetToDefaultSettings() {
        // Reset al je instellingen naar hun standaardwaarden
        isSetPlaying = false
        levelProgressExponent = 2.5
        levelDifficulty = 0.6
        videoFeedback = 0.5
        sensitivitySession = 0.5
        sensitivityDeviation = 0.0
        currentUrl = "Introductie.json"
        showPartEditor = false
        _levelSpeed = 0.1
    }
}

struct UserDefaultsKeys {
    
    static let appVersion = "appVersion"
    
    static let isSetPlaying = "isSetPlaying"
    
    static let levelSpeed = "levelSpeed"
    static let levelProgressExponent = "levelProgressExponent"
    static let levelDifficulty = "levelDifficulty"
    
    static let videoFeedback = "videoFeedback"
    static let sensitivitySession = "sensitivitySession"
    static let sensitivityDeviation = "sensitivityDeviation"
    
    static let currentUrl = "currentUrl"
    static let showPartEditor = "showPartEditor"
    
    static let persistance = "persistance"
    static let tempo = "tempo"
}
