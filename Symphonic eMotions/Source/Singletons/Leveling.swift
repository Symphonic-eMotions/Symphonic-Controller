//
//  Leveling.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 11/11/2021.
//

import Combine
import OrderedCollections

class Leveling {
    // This levels up with Area values not instruments
    var currentSetLevelSubject = CurrentValueSubject<Double, Never>(0)
}
