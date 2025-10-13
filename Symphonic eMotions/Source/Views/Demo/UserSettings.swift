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
    
    @AppStorage(UserDefaultsKeys.calibrationMin) var calibrationMin: Int = 0
    @AppStorage(UserDefaultsKeys.calibrationMax) var calibrationMax: Int = 255
    
//    @AppStorage(UserDefaultsKeys.calibrationThreshold) var calibrationThreshold: Int = 0

    // Have a observed van for states
    @Published var userCode: UserCode {
        didSet {
            // Persist to UserDefaults for re use after restart app
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

        // Regel opslag van ingevoerde user code
        if let rawValue = UserDefaults.standard.string(forKey: "userCode"),
           let initialCode = UserCode(rawValue: rawValue) {
            userCode = initialCode
        } else {
            userCode = .none
        }
    }
}

enum UserDefaultsKeys {
    static let appVersion = "appVersion"

    static let isSetPlaying = "isSetPlaying"
    static let isCapturingRunning = "isCapturingRunning"

    static let levelProgressExponent = "levelProgressExponent"

    static let videoFeedback = "videoFeedback"
    static let calibrationMin = "calibrationMin"
    static let calibrationMax = "calibrationMax"
    
    static let sensitivitySession = "sensitivitySession"
    static let sensitivityDeviation = "sensitivityDeviation"

    static let currentUrl = "currentUrl"
    static let showPartEditor = "showPartEditor"

    static let persistance = "persistance"
    static let tempo = "tempo"

    static let ipAddress = "ipAddress"
    static let port = "port"

//    static let calibrationThreshold = "calibrationThreshold"
}

extension UserDefaultsKeys {
    static let rampUpPartPrefix   = "rampUp.part."
    static let rampDownPartPrefix = "rampDown.part."

    // Legacy (alleen partId): blijft voor migratie (Deprecated)
    static func legacyRampUpKey(_ partId: String) -> String { rampUpPartPrefix + partId }
    static func legacyRampDownKey(_ partId: String) -> String { rampDownPartPrefix + partId }

    // Nieuw (trackId#partId)
    static func rampUpKey(trackId: String, partId: String) -> String {
        rampUpPartPrefix + RampKey.part(trackId, partId)
    }
    static func rampDownKey(trackId: String, partId: String) -> String {
        rampDownPartPrefix + RampKey.part(trackId, partId)
    }
}

extension UserSettings {
    // READ
    func rampUp(forTrack trackId: String, part partId: String, default defaultValue: Double) -> Double {
        let newKey = UserDefaultsKeys.rampUpKey(trackId: trackId, partId: partId)
        if let _ = UserDefaults.standard.object(forKey: newKey) {
            let v = UserDefaults.standard.double(forKey: newKey)
            return v
        }
        // migratie: legacy key zonder track
        let legacyKey = UserDefaultsKeys.legacyRampUpKey(partId)
        if let _ = UserDefaults.standard.object(forKey: legacyKey) {
            let v = UserDefaults.standard.double(forKey: legacyKey)
            UserDefaults.standard.set(v, forKey: newKey)
            return v
        }
        return defaultValue
    }

    func rampDown(forTrack trackId: String, part partId: String, default defaultValue: Double) -> Double {
        let newKey = UserDefaultsKeys.rampDownKey(trackId: trackId, partId: partId)
        if let _ = UserDefaults.standard.object(forKey: newKey) {
            let v = UserDefaults.standard.double(forKey: newKey)
            return v
        }
        // migratie: legacy key zonder track
        let legacyKey = UserDefaultsKeys.legacyRampDownKey(partId)
        if let _ = UserDefaults.standard.object(forKey: legacyKey) {
            let v = UserDefaults.standard.double(forKey: legacyKey)
            UserDefaults.standard.set(v, forKey: newKey)
            return v
        }
        return defaultValue
    }

    // WRITE
    func setRampUp(_ value: Double, forTrack trackId: String, part partId: String) {
        let key = UserDefaultsKeys.rampUpKey(trackId: trackId, partId: partId)
        UserDefaults.standard.set(value, forKey: key)
    }

    func setRampDown(_ value: Double, forTrack trackId: String, part partId: String) {
        let key = UserDefaultsKeys.rampDownKey(trackId: trackId, partId: partId)
        UserDefaults.standard.set(value, forKey: key)
    }
}

enum DebugLog {
    static var doDebug = false // zet op false als je klaar bent

    static func d(_ msg: @autoclosure () -> String) {
        guard doDebug else { return }
        print("🛠️ [Debug] \(msg())")
    }
}

enum RampKey {
    static func part(_ trackId: String, _ partId: String) -> String { "\(trackId)#\(partId)" }
}
