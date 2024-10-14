//
//  SetInfoHome.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI
import SwiftOSC

enum DevicePattern: String, CaseIterable {
    case stap1 = "/stap1"
    case stap2 = "/stap2"
    case stap3 = "/stap3"
    case stap4 = "/stap4"
    case stap5 = "/stap5"
    case stap6 = "/stap6"
    case stap7 = "/stap7"
    case stap8 = "/stap8"
    case stap9 = "/stap9"
    
    // Failable initializer om te initialiseren vanuit een string
    init?(pattern: String) {
        self.init(rawValue: pattern)
    }
}

struct SetInfoHome: View {
    
    @ObservedObject var userSettings: UserSettings
    @State private var sliderValue: Float = 0.0
    @State private var selectedPattern: DevicePattern = .stap1 // Default value

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        // Probeer het huidige pattern te matchen met een enum waarde
        if let initialPattern = DevicePattern(pattern: userSettings.pattern) {
            self._selectedPattern = State(initialValue: initialPattern)
        }
    }

    var body: some View {
        VStack {
            TextField("IP-address central DAW", text: $userSettings.ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numbersAndPunctuation)
            
            // Picker for Device Pattern
            Picker("Device Pattern", selection: $selectedPattern) {
                ForEach(DevicePattern.allCases, id: \.self) { pattern in
                    Text(pattern.rawValue).tag(pattern)
                }
            }
            .pickerStyle(MenuPickerStyle()) // Dropdown style
            .onChange(of: selectedPattern) { newValue in
                userSettings.pattern = newValue.rawValue // Update pattern in userSettings
            }
            .padding()

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
