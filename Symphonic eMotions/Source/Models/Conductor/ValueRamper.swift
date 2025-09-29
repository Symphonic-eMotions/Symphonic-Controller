//
//  ValueRamper.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 30/06/2023.
//

// import Foundation
//
// extension Conductor {
//
//    internal func valueRamper(value: Double, rampId: String) -> Double {
//
//        var valueRamped: Double = value
//
//        //We detect a value higher compared to previous one, we increase
//        if valueRamped > rampValues[rampId]! {
//            valueRamped = min(rampValues[rampId]! + valueRamped * self.rampUp[rampId]!, 0.9999999)
//        }
//        //Otherwise we need to go back to 0
//        else{
//            valueRamped = max(rampValues[rampId]! - (1 - valueRamped) * self.rampDown[rampId]!, 0)
//        }
//
//        //Memmber berries
//        rampValues[rampId] = valueRamped
//
//        return valueRamped
//    }
// }
