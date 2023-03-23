//
//  Skin.swift
//  Symphonic eMotions Pro RC
//
//  Created by Frans-Jan Wind on 31/01/2023.
//

import Foundation
import SwiftUI


extension InstrumentsSet {
    
    struct Skin: Decodable{
    
        private enum SkinKeys: String, CodingKey {
            case name
            case instruments
        }
    
        var name: String
        var instruments: [Instrument]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SkinKeys.self)
            name = try container.decode(String.self, forKey: .name)
            instruments = try container.decode([Instrument].self, forKey: .instruments)
        }
        //Ad Hoc init
        init(name: String, instruments: [Instrument]){
            self.name = name
            self.instruments = instruments
        }
    }
}

extension InstrumentsSet.Skin: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SkinKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(instruments, forKey: .instruments)
    }
}

extension InstrumentsSet.Skin {
        
    struct Instrument: Decodable {
        
        private enum SkinInstrumentKeys: String, CodingKey {
            case shape
            case name
            case image
            case color
        }
            
        var shape: String
        var name: String
        var image: String
        var color: Color
        var uiColor: UIColor
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SkinInstrumentKeys.self)
            shape = try container.decode(String.self, forKey: .shape)
            name = try container.decode(String.self, forKey: .name)
            image = try container.decode(String.self, forKey: .image)
            let colorString = try container.decodeIfPresent(String.self, forKey: .color)
            color = Color(colorString ?? "InstrumentColor000")
            uiColor = color.toUIColor()
            print("COLOR UICOLOR")
            print(color)
            print(uiColor)
        }
        
        //Ad Hoc init
        init(shape: String, name: String, image: String, color: Color){
            self.shape = shape
            self.name = name
            self.image = image
            self.color = color
            self.uiColor = color.toUIColor()
        }
    }
}



extension InstrumentsSet.Skin.Instrument: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SkinInstrumentKeys.self)
        try container.encode(shape, forKey: .shape)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        let instrumentColors = InstrumentColors()
        try container.encode(instrumentColors.name(color: color), forKey: .color)
    }
}

//extension InstrumentsSet.Skin {
//
//    enum Name {
//
////            private enum Keys: String, CodingKey {
//
//        case swiftUI = "Camera / grid"
//        case growingDots = "Growing dots"
//        case zones = "Zones"
//        case equaliser = "Equaliser"
////            }
//    }
//}

//extension InstrumentsSet.Skin {
//    
//    enum Name: String, Decodable {
//        case free = "Test Set Free"
//        case boundries = "Test Set Kaders"
//        case swiftUI = "Camera / grid"
//        case growingDots = "Growing dots"
//        case zones = "Zones"
//        case equaliser = "Equaliser"
//    }
//    
//}

//extension InstrumentsSet.Skin.Instrument {
//
//    enum Shape: String, Decodable {
//
//        case circle
//        case box
//    }
//}


