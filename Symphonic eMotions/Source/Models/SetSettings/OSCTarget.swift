//
//  OSCTarget.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 07/10/2025.
//
//  Received in Max by:
//  - route /stap1/direct
//  - ...
//  - route /stap10/direct
//

struct OSCTarget: Codable, Equatable {
    // Adressing from ValuesDidChange
    var id: String
    // External OSC Host
    var ipAddress: String
    // Communication Port (VeM Router uses 8000)
    var port: Int
    // stapN in VeM Router
    var pattern: String

    init(
        id: String = "default",
        ipAddress: String = "127.0.0.1",
        port: Int = 8000,
        pattern: String = "/stap0"
    ) {
        self.id = id
        self.ipAddress = ipAddress
        self.port = port
        self.pattern = pattern
    }
}
