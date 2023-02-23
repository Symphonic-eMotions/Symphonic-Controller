//
//  ParameterSettings.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 16/02/2023.
//

import Foundation

class ParameterSettings: Identifiable {
    
    var id: Int { index }
    var index: Int
    var name: String
    var value: Double
    var range: [Double]
    
    init( index: Int, name: String, value: Double, range: [Double] ) {
        self.index = index
        self.name = name
        self.value = value
        self.range = range
    }
}
