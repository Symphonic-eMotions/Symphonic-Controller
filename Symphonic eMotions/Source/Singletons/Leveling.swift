//
//  Leveling.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 11/11/2021.
//

import Combine
import OrderedCollections

class Leveling {
        
    //This levels up with Area values not instruments
    var currentSetLevelSubject = CurrentValueSubject<Double, Never>(0)
    var pauseLevel: Bool = false
    
    var trackLevels: [Int] = []
    
    func pauzeOpacity( isPlaying: Bool ) -> Double {
        
        var opacity: Double = 0
        
        if pauseLevel { opacity = 1 }
        else { opacity = 0.22 }
        
        if !isPlaying { opacity = 0 }
        
        return opacity
    }
}

class TrackLevelsModel: ObservableObject {
    
    var levels: [Int] = []
    
    init(trackLevels: [Int]){
        self.levels = trackLevels
    }
}
