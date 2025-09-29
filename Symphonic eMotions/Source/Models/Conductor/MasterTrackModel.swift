//
//  MasterTrackModel.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 27/09/2022.
//

import Foundation
import OrderedCollections

struct MasterTrackEffect: Identifiable, Hashable {
    var id: String { effectName }
    var effectName: String
    var parameters: [Parameter]?
}

struct TrackEffect: Identifiable, Hashable {
    var id: String { effectName }
    var effectType: String
    var effectName: String
    var parameters: [Parameter]?
}

struct Parameter: Identifiable, Hashable {
    var id: String { name }
    var type: String
    var name: String
    var value: Double
    var range: [Double]
}
