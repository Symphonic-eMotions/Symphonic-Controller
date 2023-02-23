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
    var setCollection: Sets
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
            
            
            let setSettings = AppUtils.setSettings(instrumentSet: instrumentsSet)
            
            self.partFeedback = PartFeedback(instrumentsSet: instrumentsSet)
            
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
                    setSetting: setSettings,
                    sessionSetting: sessionSettings
                ),
                setCollection: mainState.setCollection,
                currentInstrumentsSet: instrumentsSet,
                buildSettings: mainState.buildSettings
            )
            
            //Here we are
//            mainState.buildSettings.activeView = .playView
            
            print("---> LOADING NEW SETSETTINGS")
            
//            if mainState.buildSettings.mainSettings == .muur {
                mainState.buildSettings.activeView = .playView
//            }
            
            //The engine startup is located in the FullPlayView.onAppear
            //Or in the transport button PlayView
            print("\(mainState.setSettings.setName) \(mainState.setSettings.gridColumns)x\(mainState.setSettings.gridRows) Session maxValue: \(mainState.sessionSettings.imageMax) imageFeedback: \(mainState.sessionSettings.imageFeedback)")
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
    
    func backButton() {
        
        print("Lets go back!")
        
        conductor.pauzeEngineAndStopTracks(setSettings: mainState.setSettings)
        
        mainState.buildSettings.activeView = .homeView
    }
    
    func backButtonSkins() {
        
        print("Lets go back, but now for skins!")
        
        conductor.pauzeEngineAndStopTracks(setSettings: mainState.setSettings)
        
        mainState.buildSettings.activeView = .homeView
    }
}
