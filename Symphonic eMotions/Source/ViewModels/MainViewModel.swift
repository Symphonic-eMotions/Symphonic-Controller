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
    var semActive: SeMActive
    var masterTrackStructure: [MasterTrackEffect]?
}

final class MainViewModel: ObservableObject {
    
    
    @Published var mainState: MainViewState
    var userSettings: UserSettings
    let conductor: Conductor
    let leveling: Leveling
    var partFeedback: PartFeedback
    
    init(
        mainState: MainViewState,
        conductor: Conductor,
        leveling: Leveling,
        partFeedback: PartFeedback,
        userSettings: UserSettings = UserSettings.shared
    ) {
        self.mainState = mainState
        self.conductor = conductor
        self.leveling = leveling
        self.partFeedback = partFeedback
        self.userSettings = userSettings
    }
    
    func currentModelInstrumentsSetChanged(
        instrumentsSet: InstrumentsSet
    ) {
        //Reset leveling
        leveling.currentSetLevelSubject.send(0)
        
        //If we're playing first stop playing
        if userSettings.isSetPlaying {
            conductor.pauzeEngineAndStopTracks(
                setSettings: self.mainState.setSettings,
                resetLevels: true
            )
            userSettings.isSetPlaying = false
            userSettings.isCapturingRunning = false
            
        } else {
            
            userSettings.isCapturingRunning = false
            
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
                semActive: mainState.semActive
            )
            print("*** sending sensitivity + deviation \(userSettings.sensitivitySession) + \(userSettings.sensitivityDeviation) and feedback \(userSettings.videoFeedback) ***")
            
            mainState.imageDifference.feedback.send(Float(userSettings.videoFeedback))
            mainState.imageDifference.sensitivityToMaxValue(
                sensitivityPlusDeviation: Float(userSettings.sensitivitySession + userSettings.sensitivityDeviation))
        }
    }
}
