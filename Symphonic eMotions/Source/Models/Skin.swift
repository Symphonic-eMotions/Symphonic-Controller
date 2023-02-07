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
    
        var name: Skin.Name
        var instruments: [Instrument]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SkinKeys.self)
            name = try container.decode(Skin.Name.self, forKey: .name)
            instruments = try container.decode([Instrument].self, forKey: .instruments)
        }
        //Ad Hoc init
        init(name: Skin.Name, instruments: [Instrument]){
            self.name = name
            self.instruments = instruments
        }
    }
}

extension InstrumentsSet.Skin {
        
    struct Instrument: Decodable {
        
        private enum SkinInstrumentKeys: String, CodingKey {
            case shape
            case image
            case color
        }
            
        var shape: Shape
        var image: String
        var color: UIColor
        var areas: [[Int]] = []
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SkinInstrumentKeys.self)
            shape = try container.decode(Shape.self, forKey: .shape)
            image = try container.decode(String.self, forKey: .image)
            let colorRaw:[Int] = try container.decode([Int].self, forKey: .color)
            color = UIColor(
                red: CGFloat(colorRaw[0]/255),
                green: CGFloat(colorRaw[1]/255),
                blue: CGFloat(colorRaw[2]/255), alpha: 1)
        }
        
        //Ad Hoc init
        init(shape: Shape, image: String, color: UIColor, areas: [[Int]]){
            self.shape = shape
            self.image = image
            self.color = color
            self.areas = areas
        }
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

extension InstrumentsSet.Skin {
    
    enum Name: String, Decodable {
        case swiftUI = "Camera / grid"
        case growingDots = "Growing dots"
        case zones = "Zones"
        case equaliser = "Equaliser"
    }
    
}

extension InstrumentsSet.Skin.Instrument {
    
    enum Shape: String, Decodable {
        
        case circle
        case box
    }
}


