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
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    @AppStorage(UserDefaultsKeys.levelSpeed) var levelSpeed: Double = 1
    
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
        if let rawValue = UserDefaults.standard.string(forKey: "userCode"),
           let initialCode = UserCode(rawValue: rawValue) {
            self.userCode = initialCode
        } else {
            self.userCode = .none
        }
    }
}

struct UserDefaultsKeys {
    
    static let isSetPlaying = "isSetPlaying"
    static let levelSpeed = "levelSpeed"
    
    static let videoFeedback = "videoFeedback"
    static let sensitivitySession = "sensitivitySession"
    static let sensitivityDeviation = "sensitivityDeviation"
    
    static let currentUrl = "currentUrl"
    static let showPartEditor = "showPartEditor"
    
    static let persistance = "persistance"
    static let tempo = "tempo"
    
    
    
}
