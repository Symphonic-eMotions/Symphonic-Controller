//
//  SetInfoHome.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI
import SwiftOSC

struct SetInfoHome: View {
    
    @ObservedObject var userSettings: UserSettings

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }

    var body: some View {
        HStack {
            Text("IP-address central DAW")
            TextField("", text: $userSettings.ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numbersAndPunctuation)
            
        }
    }
}
