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
    
    @AppStorage(UserDefaultsKeys.ipAddress) var ipAddress: String = "172.20.10.99"
    @AppStorage(UserDefaultsKeys.port) var port: Int = 8000
    @AppStorage(UserDefaultsKeys.pattern) var pattern: String = "/stap1"
    
    @AppStorage(UserDefaultsKeys.calibrationThreshold) var calibrationThreshold: Int = 0
    
    @AppStorage(UserDefaultsKeys.rampUp) var rampUp: Double = 0.0
    @AppStorage(UserDefaultsKeys.rampDown) var rampDown: Double = 0.0
    
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
    
    func getRampUp(for pattern: DevicePattern, defaultValue: Double) -> Double {
       let key = UserDefaultsKeys.rampUp + "_" + pattern.rawValue
       if UserDefaults.standard.object(forKey: key) == nil {
           // If no value is stored, return the default value
           return defaultValue
       }
       return UserDefaults.standard.double(forKey: key)
   }

   func setRampUp(_ value: Double, for pattern: DevicePattern) {
       let key = UserDefaultsKeys.rampUp + "_" + pattern.rawValue
       UserDefaults.standard.set(value, forKey: key)
   }

   func getRampDown(for pattern: DevicePattern, defaultValue: Double) -> Double {
       let key = UserDefaultsKeys.rampDown + "_" + pattern.rawValue
       if UserDefaults.standard.object(forKey: key) == nil {
           // If no value is stored, return the default value
           return defaultValue
       }
       return UserDefaults.standard.double(forKey: key)
   }

   func setRampDown(_ value: Double, for pattern: DevicePattern) {
       let key = UserDefaultsKeys.rampDown + "_" + pattern.rawValue
       UserDefaults.standard.set(value, forKey: key)
   }}

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
    
    static let ipAddress = "ipAddress"
    static let port = "port"
    static let pattern = "pattern"
    
    static let calibrationThreshold = "calibrationThreshold"
    
    static let rampUp = "rampUp"
    static let rampDown = "rampDown"
}
