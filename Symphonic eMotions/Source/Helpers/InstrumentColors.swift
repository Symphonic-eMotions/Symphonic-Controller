//
//  InstrumentColors.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 21/10/2022.
//

import Foundation
import SwiftUI

struct InstrumentColors {
    
    var palet: [Color] = [
        Color("InstrumentColor000"),
        Color("InstrumentColor001"),
        Color("InstrumentColor002"),
        Color("InstrumentColor100"),
        Color("InstrumentColor200"),
        Color("InstrumentColor300"),
        Color("InstrumentColor400"),
        Color("InstrumentColor500"),
        Color("InstrumentColor600"),
        Color("InstrumentColor601"),
        Color("InstrumentColor602"),
        Color("InstrumentColor700"),
        Color("InstrumentColor701"),
        Color("InstrumentColor702"),
        Color("InstrumentColor800"),
        Color("InstrumentColor801"),
        Color("InstrumentColor802"),
        Color("Skin0"),
        Color("Skin1"),
        Color("Skin2")
    ]
    
    public func name( color: Color ) -> String {
        
        switch color {
            
        case Color("InstrumentColor000"):
            return "InstrumentColor000"
        
        case Color("InstrumentColor001"):
            return "InstrumentColor001"
        
        case Color("InstrumentColor002"):
            return "InstrumentColor002"
            
        case Color("InstrumentColor100"):
            return "InstrumentColor100"
            
        case Color("InstrumentColor200"):
            return "InstrumentColor200"
            
        case Color("InstrumentColor300"):
            return "InstrumentColor300"
            
        case Color("InstrumentColor400"):
            return "InstrumentColor400"
            
        case Color("InstrumentColor500"):
            return "InstrumentColor500"
            
        case Color("InstrumentColor600"):
            return "InstrumentColor600"
            
        case Color("InstrumentColor601"):
            return "InstrumentColor601"
            
        case Color("InstrumentColor602"):
            return "InstrumentColor602"
            
        case Color("InstrumentColor700"):
            return "InstrumentColor700"
            
        case Color("InstrumentColor701"):
            return "InstrumentColor701"
            
        case Color("InstrumentColor702"):
            return "InstrumentColor702"
            
        case Color("InstrumentColor800"):
            return "InstrumentColor800"
            
        case Color("InstrumentColor801"):
            return "InstrumentColor800"
            
        case Color("InstrumentColor802"):
            return "InstrumentColor802"
            
        case Color("Skin0"):
            return "Skin0"
            
        case Color("Skin1"):
            return "Skin1"
            
        case Color("Skin2"):
            return "Skin2"
        
        default: return "InstrumentColor000"
        }
    }
}
