//
//  ValueDamper.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 30/06/2023.
//

// import Foundation
//
// extension Conductor {
//
//    internal func valueDamper(
//        dampMode: InstrumentsSet.Track.Part.DamperTarget.DampMode,
//        value: Double) -> Double {
//
//            var valueRamped: Double = value
//
//            if dampMode == .easeInCircular {
//                valueRamped = EaseInCircularDamper().damp(value: valueRamped)
//            }
//            else if dampMode == .easeInCubic {
//                valueRamped = EaseInCubicDamper().damp(value: valueRamped)
//            }
//            else if dampMode == .easeOutCubic {
//                valueRamped = EaseOutCubicDamper().damp(value: valueRamped)
//                //Remove unwanted offset
//                valueRamped = valueRamped - 0.25
//                valueRamped = valueRamped * 1.25
//            }
//            else if dampMode == .easeInOutCubic {
//                valueRamped = EaseInOutCubicDamper().damp(value: valueRamped)
//                //Add missing top values
//                valueRamped = valueRamped * 1.25
//            }
//
//            return valueRamped
//        }
// }
