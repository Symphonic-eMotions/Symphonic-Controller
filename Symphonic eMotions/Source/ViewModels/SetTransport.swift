//
//  SetTransport.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 19/07/2023.
//

import Foundation

extension SetInfoModel {
    
    func tapStopAudioEngine(){
        conductor.pauzeEngineAndStopTracks(
            setSettings: self.setSettings,
            resetLevels: false
        )
    }
    
    func tapStartAudioEngine(){
        
        //Fade in on master play, we need level.currentlevel here
        conductor.levelController(
            level: Int(leveling.currentSetLevelSubject.value),
            setSettings: self.setSettings
        )

        conductor.playEngineAndTracks(
            setSettings: self.setSettings,
            level: Int(leveling.currentSetLevelSubject.value)
        )
    }
    
    func tapSetTempoBPMPlus(){
        self.setSettings.bpm += 1
        let _ = self.conductor.setTempo(tempoChange: 5)
    }
    
    func tapSetTempoBPMMin(){
        self.setSettings.bpm -= 1
        let _ = self.conductor.setTempo(tempoChange: -5)
    }
    
    func tapSetTempoReset(){
        
        let tempo = self.conductor.resetTempo()
        self.setSettings.bpm = tempo
    }
    
    func tapDisplayModeChange() {
        switch setInfoState.displayMode {
        case .off:
            setInfoState.displayMode = .video
        case .video:
            setInfoState.displayMode = .instruments
        case .instruments:
            setInfoState.displayMode = .both
        case .both:
            setInfoState.displayMode = .off
        case .refresh:
            return
        }
        playerControlsAction?(.displayModeChange(setInfoState.displayMode))
    }
}
