//
//  PartFeedback.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 28/05/2022.
//

import Combine

class PartFeedback {
    
    // What track are we showing?
    var currentTrackID = CurrentValueSubject<String, Never>("")
    
    // What part of this track are we showing
    var currentPartID = CurrentValueSubject<String, Never>("")
    
    // Show value after Ramp
    var ramped = CurrentValueSubject<Double, Never>(0)
    
    init(instrumentsSet: InstrumentsSet){
        // Optionele binding om veilig het eerste track op te halen
        if let firstTrack = instrumentsSet.tracks.first {
            self.currentTrackID.send(firstTrack.trackId)
            
            // Optionele binding om veilig het eerste part van het eerste track op te halen
            if let firstPart = firstTrack.parts.first {
                self.currentPartID.send(firstPart.id)
            } else {
                // Geen eerste part gevonden, eventueel hier een standaardwaarde instellen of een log/foutmelding
                print("Geen eerste part gevonden")
            }
        } else {
            // Geen eerste track gevonden, eventueel hier een standaardwaarde instellen of een log/foutmelding
            print("Geen eerste track gevonden")
        }
    }
}

