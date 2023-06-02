//
//  FileGroup.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 02/06/2023.
//

import Foundation

enum FileGroup: Hashable, Codable {
    
    case template
    case demo
    case pro
    case art
    case none
    
    var title: String {
        switch self {
        case .template:
            return "Template"
        case .demo:
            return "Demo"
        case .pro:
            return "Pro"
        case .art:
            return "Art"
        case .none:
            return "None"
        }
    }
}
