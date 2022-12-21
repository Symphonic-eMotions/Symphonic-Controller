//
//  RangeConverter.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 18/09/2022.
//

import Foundation

final class RangeConverter {
    
    static func valueToRange(range: [Double], value: Double, exponent: Int = 0, inverted: Bool = false ) -> Double {
        
        var expValue = value
        
        if exponent > 0 { // == 1
            expValue = expValue * value
        }
        else if exponent > 1 { // == 2
            expValue = expValue * value
        }
        else if exponent > 2 { // == 3 ()
            expValue = expValue * value
        }
        
        if inverted { expValue = expValue * -1 + 1 }
        
        let r = expValue * (abs(range[0]) + range[1]) + range[0]

        return r
    }
    
    static func rangeToValue(range: [Double], value: Double) -> Double {
        
        var r: Double = 0.0
        r = (value * (abs(range[0]) + range[1])) + range[0]
        
        return r
    }
    
    static func rangedToSlider(range: [Double], value: Double) -> Float{
        
        let rangePart: Double = 1 / (abs(range[0]) + range[1])
        
        var r: Double = value * rangePart
        
        if range[0] < 0 {
            r = r + abs(range[0]) * rangePart
        }
        
        return Float(r)
    }
}

