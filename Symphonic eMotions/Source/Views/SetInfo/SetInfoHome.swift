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
    @State private var sliderValue: Float = 0.0
    

    var body: some View {
        VStack {
            TextField("IP-address central DAW", text: $userSettings.ipAddress)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .keyboardType(.numbersAndPunctuation)
            
            TextField("Device Pattren", text: $userSettings.pattern)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .keyboardType(.numbersAndPunctuation)

            Slider(value: $sliderValue, in: 0...1)
            .padding()
            .onChange(of: sliderValue) { newValue in
                OSCMessageSender.shared.sendOSCMessage(
                    ipAddress: userSettings.ipAddress,
                    port: userSettings.port,
                    pattern: userSettings.pattern,
                    value: newValue
                )
            }
        }
    }
}
