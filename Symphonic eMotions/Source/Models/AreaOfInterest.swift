//
//  AreaOfInterest.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 24/10/2022.
//

import Foundation
import SwiftUI

class AreaOfInterestColors: ObservableObject {
    
    let id = UUID()
    var partId: String
    var colors: [Color]
    
    init( partId: String, colors: [Color]) {
        self.partId = partId
        self.colors = colors
    }
    
}
