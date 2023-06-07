//
//  VariationType.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import Foundation

enum VariationType: String, Codable, CaseIterable {
    
    case variationByLevel
    case variationByPosition
    case variationByIntensity
    case variationSequencial
    
    var description: String {
        switch self{
        case .variationByLevel:
            return "Variation by level"
        case .variationByPosition:
            return "Variation by position"
            
        case .variationByIntensity:
            return "Variation by intensity"
        case .variationSequencial:
            return "Sequencial variation"
        }
    }
}
