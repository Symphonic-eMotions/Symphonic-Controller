//
//  SetInfoHome.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI
import SwiftOSC

import SwiftUI
import SwiftOSC

struct SetInfoHome: View {

    @State private var sliderValue: Float = 0.0
    @AppStorage("ipAddress") var ipAddress: String = "192.168.178.22"
    @AppStorage("pattern") var pattern: String = "/makeMeUnique"
    @State private var port: UInt16 = 8000

    var body: some View {
        VStack {
            TextField("IP-address central DAW", text: $ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numbersAndPunctuation)
            
            TextField("Device Pattren", text: $pattern)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numbersAndPunctuation)

            Slider(value: $sliderValue, in: 0...1)
                .padding()
                .onChange(of: sliderValue) { newValue in
                    sendOSCMessage(newValue)
                }
        }
    }

    func sendOSCMessage(_ value: Float) {
        let client = OSCClient(address: ipAddress, port: Int(port))
        let address = OSCAddressPattern(pattern)
        let message = OSCMessage(address, value)
        client.send(message)
    }
}
