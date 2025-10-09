//
//  OSCMessageSender.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/10/2024.
//  Updated by Frans-Jan Wind on 9/10/2024
//

import SwiftOSC

class OSCMessageSender {
    static let shared = OSCMessageSender()
    private init() {}

    private var clients: [String: OSCClient] = [:]

    // cache de client per ip:port zodat je niet telkens nieuwe maakt
    private func client(for ip: String, port: Int) -> OSCClient {
        let key = "\(ip):\(port)"
        if let c = clients[key] { return c }
        let new = OSCClient(address: ip, port: port)
        clients[key] = new
        return new
    }

    /// Stuur één float-waarde (zoals voorheen)
    func sendOSCMessage(ipAddress: String, port: Int, pattern: String, value: Float) {
        let address = OSCAddressPattern(pattern)
        let message = OSCMessage(address, value)
        client(for: ipAddress, port: port).send(message)
    }

//    /// 🧺 Nieuw: stuur een bundle met meerdere messages tegelijk
//    func sendOSCBundle(ipAddress: String,
//                       port: Int,
//                       messages: [(pattern: String, value: Float)]) {
//        guard !messages.isEmpty else { return }
//        let elements = messages.map { (pattern, value) in
//            OSCMessage(OSCAddressPattern(pattern), value)
//        }
//        let bundle = OSCBundle(elements)
//        client(for: ipAddress, port: port).send(bundle)
//    }

    /// 📦 Alternatief: één message met meerdere floats
    func sendOSCMessage(ipAddress: String,
                        port: Int,
                        pattern: String,
                        values: [Float]) {
        guard !values.isEmpty else { return }
        let address = OSCAddressPattern(pattern)
        let message = OSCMessage(address, values.map { $0 })
        client(for: ipAddress, port: port).send(message)
    }
}
