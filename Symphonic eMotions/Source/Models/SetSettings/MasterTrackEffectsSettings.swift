//
//  MasterTrackEffectsSettings.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 16/02/2023.
//

import Foundation
import OrderedCollections

class MasterTrackEffectsSettings: Identifiable {
    
    var id: Int { index }
    var index: Int
    var name: String
    var parameters: OrderedDictionary<Int, ParameterSettings>
    
    init(
        index: Int,
        name: String,
        parameters: OrderedDictionary<Int, ParameterSettings>
    ) {
        self.index = index
        self.name = name
        self.parameters = parameters
    }
}
