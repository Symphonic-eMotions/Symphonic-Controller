//
//  MainViewModel.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 15/09/2022.
//

import SwiftUI

struct MainViewState {
    var setSettings: SetSettings
    var imageDifference: ImageDifference
    var currentInstrumentsSet: InstrumentsSet
    var buildSettings: BuildSettings
    var masterTrackStructure: [MasterTrackEffect]?
}

final class MainViewModel: ObservableObject {
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    //Convert to Float
    private let appStorage = UserDefaults.standard
    var sensitivity: Float  {
        appStorage.float(forKey: "sensitivity")
    }
    var videoFeedback: Float  {
        appStorage.float(forKey: "videoFeedback")
    }
    
    @Published var mainState: MainViewState
    let conductor: Conductor
    let leveling: Leveling
    var partFeedback: PartFeedback
    
    init(
        mainState: MainViewState,
        conductor: Conductor,
        leveling: Leveling,
        partFeedback: PartFeedback
    ) {
        self.mainState = mainState
        self.conductor = conductor
        self.leveling = leveling
        self.partFeedback = partFeedback
    }
    
    func currentModelInstrumentsSetChanged(
        instrumentsSet: InstrumentsSet
    ) {
    
        //Reset leveling
        leveling.currentSetLevelSubject.send(0)
        
        //If we're playing first stop playing
        if isSetPlaying {
            
            leveling.pauseLevel = true
            conductor.togglePlayEngineAndTracks(
                currentSetLevel: leveling.currentSetLevelSubject.value,
                setSettings: mainState.setSettings
            )
            
        } else {
                        
            let setSettings = AppUtils.setSettings(
                instrumentSet: instrumentsSet
            )
            
            //Editor Instrument Part visual feedback connector
            self.partFeedback = PartFeedback(instrumentsSet: instrumentsSet)
            
            //Load all sequencers, audio generators and effects
            conductor.currentConductorInstrumentsSetChanged(
                newInstrumentsSet: instrumentsSet,
                currentSetLevel: leveling.currentSetLevelSubject.value,
                setSettings: setSettings
            )
            
            //Video analysis vars
            //And the loaded instrument set
            mainState = MainViewState(
                setSettings: setSettings,
                imageDifference: ImageDifference(
                    setSetting: setSettings
                ),
                currentInstrumentsSet: instrumentsSet,
                buildSettings: mainState.buildSettings
            )
            print("*** loading sensitivity \(sensitivity) and feedback \(videoFeedback) to imageDifference ***")
            
            mainState.imageDifference.feedback.send(videoFeedback)
            mainState.imageDifference.sensitivityToMaxValue(sensitivity: sensitivity)
        }
    }
}
