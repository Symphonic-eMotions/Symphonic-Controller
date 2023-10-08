//
//  UserCode.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import Foundation

enum UserCode: String {
    case none
    case creator
}

class UserSettings: ObservableObject {
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
