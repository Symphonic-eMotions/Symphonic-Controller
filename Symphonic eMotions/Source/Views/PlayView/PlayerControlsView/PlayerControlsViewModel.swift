//
//  PlayerControlsViewModel.swift
//  Symphonic eMotions
//
//  Created by Çağatay Emekci on 7.04.2022.
//
import SwiftUI

struct PlayerControlsViewState {
    var displayMode: DisplayModes
    var buildSettings: BuildSettings
}

enum PlayerControlsViewAction {
    case displayModeChange(DisplayModes)
    case settingsChange(Bool)
    case partFeedbackViewChange(Bool)
    case masterTrackViewChange(Bool)
}

final class PlayerControlsViewModel: ObservableObject {
    
    let conductor: Conductor
    let frameExtractor: FrameExtractor
    let leveling: Leveling
    var setSettings: SetSettings
    let playerControlsAction: (PlayerControlsViewAction) -> Void
    let hasTempo: Bool

    @Published var playerControlsViewState: PlayerControlsViewState
    
    init(
        playerControlsViewState: PlayerControlsViewState,
        conductor: Conductor,
        frameExtractor: FrameExtractor,
        leveling: Leveling,
        setSettings: SetSettings,
        hasTempo: Bool,
        playerControlsAction: @escaping (PlayerControlsViewAction) -> Void
    ) {
        self.conductor = conductor
        self.frameExtractor = frameExtractor
        self.leveling = leveling
        self.setSettings = setSettings
        self.playerControlsViewState = playerControlsViewState
        self.hasTempo = hasTempo
        self.playerControlsAction = playerControlsAction
    }
    
    func tapSetTempoPlus(){
        self.conductor.setTempo(tempoChange: 5)
    }
    
    func tapSetTempoMin(){
        self.conductor.setTempo(tempoChange: -5)
    }
    
    func tapMediaControlButton() {
        leveling.pauseLevel = conductor.isConductorPlayingSubject.value
        conductor.togglePlayEngineAndTracks(
            currentSetLevel: leveling.currentSetLevelSubject.value,
            setSettings: self.setSettings
        )
    }
    
    func tapDisplayModeChange() {
        switch playerControlsViewState.displayMode {
        case .off:
            playerControlsViewState.displayMode = .video
        case .video:
            playerControlsViewState.displayMode = .instruments
        case .instruments:
            playerControlsViewState.displayMode = .both
        case .both:
            playerControlsViewState.displayMode = .off
        case .refresh:
            return
        }
        playerControlsAction(.displayModeChange(playerControlsViewState.displayMode))
    }
    
    func refreshDisplayModeChange() {
        //FIXME: This is not working? View does not get updated
        playerControlsAction(.displayModeChange(.off))
        playerControlsAction(.displayModeChange(playerControlsViewState.displayMode))
    }
    
    func tapSettingsButton() {
        playerControlsViewState.buildSettings.isAdvanced.toggle()
        playerControlsAction(.settingsChange(playerControlsViewState.buildSettings.isAdvanced))
        refreshDisplayModeChange()
    }
    
    func tapMasterFxButton() {
        playerControlsViewState.buildSettings.isMasterTrack.toggle()
        playerControlsAction(.masterTrackViewChange(playerControlsViewState.buildSettings.isMasterTrack))
    }
    
    func tapPartFeedbackButton() {
        playerControlsViewState.buildSettings.instrumentPartEditor.toggle()
        playerControlsAction(.partFeedbackViewChange(playerControlsViewState.buildSettings.instrumentPartEditor))
        refreshDisplayModeChange()
    }
}
