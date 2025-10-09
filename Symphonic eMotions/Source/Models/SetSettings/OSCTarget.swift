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
    // stapN in VeM Router
    var pattern: String

    init(
        id: String = "default",
        pattern: String = "/stap0"
    ) {
        self.id = id
        self.pattern = pattern
    }
}
