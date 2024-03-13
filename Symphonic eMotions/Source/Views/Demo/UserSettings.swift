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
        
        let levelSpeedDefault:Double = 0.1
        
        // Eerst, initialiseer alle properties die niet afhankelijk zijn van 'self'
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.appVersion) != UserSettings.currentSettingsVersion {
            // Stel de standaardwaarden in zonder resetToDefaultSettings() aan te roepen
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isSetPlaying)
            UserDefaults.standard.set(2.5, forKey: UserDefaultsKeys.levelProgressExponent)
            UserDefaults.standard.set(0.67, forKey: UserDefaultsKeys.levelDifficulty)
            UserDefaults.standard.set(0.5, forKey: UserDefaultsKeys.videoFeedback)
            UserDefaults.standard.set(0.8, forKey: UserDefaultsKeys.sensitivitySession)
            UserDefaults.standard.set(0, forKey: UserDefaultsKeys.sensitivityDeviation)
            UserDefaults.standard.set("Introductie.json", forKey: UserDefaultsKeys.currentUrl)
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.showPartEditor)
            // Aangezien _levelSpeed rechtstreeks uit UserDefaults komt
            UserDefaults.standard.set(levelSpeedDefault, forKey: UserDefaultsKeys.levelSpeed)
            //Update opgeslagen versie
            UserDefaults.standard.set(UserSettings.currentSettingsVersion, forKey: UserDefaultsKeys.appVersion)
        }
        
        // Gebruik dan 'self' na alle properties geïnitialiseerd zijn
        _levelSpeed = UserDefaults.standard.double(forKey: UserDefaultsKeys.levelSpeed)
        
        //Regel opslag van ingevoerde user code
        if let rawValue = UserDefaults.standard.string(forKey: "userCode"),
           let initialCode = UserCode(rawValue: rawValue) {
            self.userCode = initialCode
        } else {
            self.userCode = .none
        }
        
        // Voor properties die niet door @AppStorage worden beheerd, zoals _levelSpeed,
        // controleer of er al een waarde bestaat en stel deze in, gebruikmakend van de directe toegang tot UserDefaults.
        let storedLevelSpeed = UserDefaults.standard.double(forKey: UserDefaultsKeys.levelSpeed)
        if storedLevelSpeed == 0 {
            // Dit betekent dat er geen waarde is opgeslagen, dus gebruik de standaardwaarde.
            // Dit kan het geval zijn als de versiecontrole hierboven de standaardwaarden reset.
            _levelSpeed = levelSpeedDefault
        } else {
            // Gebruik de opgeslagen waarde.
            _levelSpeed = storedLevelSpeed
        }
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
