//
//  PartFeedbackState.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 15/09/2022.
//

import Foundation

struct PartFeedbackState {
//    var setSettings: SetSettings
    var currentTrackID: String
    var currentPartID: String

    // Feedback from new area value
    var ramped: Double

    init() {
        currentTrackID = ""
        currentPartID = ""
        ramped = 0
    }
}
