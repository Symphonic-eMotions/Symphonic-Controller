//
//  VisualFeedback.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 15/09/2022.
//

import Foundation

struct PartFeedbackState {
    
//    var setSettings: SetSettings
    var currentTrackID: String
    var currentPartID: String
    
    //Feedback from new area value
    var ramped: Double
    
    init(){
        self.currentTrackID = ""
        self.currentPartID = ""
        self.ramped = 0
    }
}

struct FeedbackObjectsState {
    var objectOne: Double
    var objectTwo: Double
    var objectThree: Double
    var objectFour: Double
    
    init() {
        self.objectOne = 0
        self.objectTwo = 0
        self.objectThree = 0
        self.objectFour = 0
    }
}
