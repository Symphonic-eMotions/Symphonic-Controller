//
//  SetInfoModelTransport.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 19/07/2023.
//

import Foundation

extension SetInfoModel {
    func tapStopAudioEngine() {
        conductor.pauzeEngineAndStopTracks(
            setSettings: setSettings,
            resetLevels: false
        )
    }

    func tapStartAudioEngine() {
        // Fade in on master play, we need level.currentlevel here
        conductor.levelController(
            level: Int(leveling.currentSetLevelSubject.value),
            setSettings: setSettings
        )

        conductor.playEngineAndTracks(
            setSettings: setSettings,
            level: Int(leveling.currentSetLevelSubject.value)
        )

        setSettings.isWavePlaying = false
    }

    func tapAStartRecordTracks() {
        // Start playing if not playing
        if !userSettings.isSetPlaying {
            conductor.playEngineAndTracks(
                setSettings: setSettings,
                level: Int(leveling.currentSetLevelSubject.value)
            )
        }

        // Start recording all tracks separate
        conductor.startRecordingTracks(
            setSettings: setSettings
        )
    }

    func tapStopRecordTracks() {
        // Stop recording
        conductor.stopRecordingTracks(
            setSettings: setSettings
        )

        conductor.pauzeEngineAndStopTracks(
            setSettings: setSettings,
            resetLevels: false
        )
    }

    func tapSetTempoBPMPlus() {
        setSettings.bpm += 1
        _ = conductor.setTempo(tempoChange: 5)
    }

    func tapSetTempoBPMMin() {
        setSettings.bpm -= 1
        _ = conductor.setTempo(tempoChange: -5)
    }

    func tapSetTempoReset() {
        let tempo = conductor.resetTempo()
        setSettings.bpm = tempo
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
