//
//  MainViewModel.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 15/09/2022.
//

import SwiftUI

struct MainViewState {
    var sessionSettings: SessionSettings
    var setSettings: SetSettings
    var imageDifference: ImageDifference
//    var setCollection: Sets
    var currentInstrumentsSet: InstrumentsSet
    var buildSettings: BuildSettings
    var masterTrackStructure: [MasterTrackEffect]?
}

final class MainViewModel: ObservableObject {
    
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
        instrumentsSet: InstrumentsSet,
        sessionSettings: SessionSettings
    ) {
        
        //Reload from file, the sensitivitySlider saves to file, not to session
        let sessionSettingsLoaded = AppUtils.setSessionSetting()
        //A defaut SKIN is loaded at this point.
        //We are going to overwrite the colors to the colors of the instrument within the set
        
        let currentSensitivity = sessionSettingsLoaded.sensitivity
        
        //Reset leveling
        leveling.currentSetLevelSubject.send(0)
        
        //If we're playing first stop playing
        if conductor.isConductorPlayingSubject.value {
            
            leveling.pauseLevel = true
            conductor.togglePlayEngineAndTracks(
                currentSetLevel: leveling.currentSetLevelSubject.value,
                setSettings: mainState.setSettings
            )
            
        } else {
                        
            let setSettings = AppUtils.setSettings(
                instrumentSet: instrumentsSet,
                sessionSettings: sessionSettingsLoaded
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
                sessionSettings: sessionSettings,
                setSettings: setSettings,
                imageDifference: ImageDifference(
                    setSetting: setSettings
                ),
//                setCollection: mainState.setCollection,
                currentInstrumentsSet: instrumentsSet,
                buildSettings: mainState.buildSettings
            )
            print("YYY loading sensitivity \(currentSensitivity) to imageDifference subjects")
            
            mainState.imageDifference.sensitivitySubject.value = currentSensitivity
            mainState.imageDifference.sensitivityToFeedback(sensitivity: currentSensitivity)
            mainState.imageDifference.sensitivityToMaxValue(sensitivity: currentSensitivity)
        }
    }
    
    //These function are for the SwiftUI View also available in PlayerControlsModel
    func tapStopAudioEngine(){
        conductor.pauzeEngineAndStopTracks(setSettings: self.mainState.setSettings)
    }
    
    func tapSetTempoPlus(){
        let currentTempo = self.conductor.setTempo(tempoChange: 5)
        self.mainState.setSettings.bpm = currentTempo
    }
    
    func tapSetTempoMin(){
        let currentTempo = self.conductor.setTempo(tempoChange: -5)
        self.mainState.setSettings.bpm = currentTempo
    }
    
    func tapSetTempoReset(){
        
        let tempo = self.conductor.resetTempo()
        self.mainState.setSettings.bpm = tempo
    }
}
