//
//  PartFeedback.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 28/05/2022.
//

import Combine

class PartFeedback {
    
    //What track are we showing?
    var currentTrackID = CurrentValueSubject<String, Never>("")
    
    //What part of this track are we showing
    var currentPartID = CurrentValueSubject<String, Never>("")
    
    //Show value after Damp
//    var damped = CurrentValueSubject<Double, Never>(0)
    
    //Show value after Ramp
    var ramped = CurrentValueSubject<Double, Never>(0)
    
    init(instrumentsSet: InstrumentsSet){

        self.currentTrackID.send(instrumentsSet.tracks.first!.trackId)
        self.currentPartID.send(instrumentsSet.tracks.first!.parts.first!.id)
    }
}
