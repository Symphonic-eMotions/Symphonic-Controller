//
//  EaseInCubicDamper.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 03.02.2022.
//

import Foundation

struct EaseInCircularDamper: Damper {
    
    //expr  -1 * ( sqrt( 1 - $f1 * $f1 ) -1 )
    
    func damp(value: Double) -> Double { -1 * ( sqrt( 1 - value * value ) - 1 ) }
}
