//
//  OSCMessageSender.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/10/2024.
//

import SwiftOSC

class OSCMessageSender {
    static let shared = OSCMessageSender()
    
    private init() {} // Singleton pattern
    
    func sendOSCMessage(ipAddress: String, port: Int, pattern: String, value: Float) {
        let client = OSCClient(address: ipAddress, port: port)
        let address = OSCAddressPattern(pattern)
        let message = OSCMessage(address, value)
        client.send(message)
    }
}

