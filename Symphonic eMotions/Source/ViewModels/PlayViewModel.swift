//
//  PlayViewModel.swift
//  PlayViewModel
//
//  Created by Mihai Fratu on 31.07.2021.
//

import UIKit
import Combine
import SwiftUI

struct PlayViewState {
    var currentInstrumentsSet: InstrumentsSet
    var currentLevel: Double = 0.0 //Leveling
    var values: [[AreaValues]] = []
    var displayMode: DisplayModes = .both
    var displayOpacity: Float = 0.12
    var buildSettings: BuildSettings
    var masterTrackStructure: [MasterTrackEffect]?
    var updateEditView: Int = 0
}

final class PlayViewModel: ObservableObject {
    
    private(set) var frameExtractor: FrameExtractor
    
    let leveling: Leveling
    var conductor: Conductor
    @Published var playViewState: PlayViewState
    @Binding var imageDifference: ImageDifference
    var cancellables = Swift.Set<AnyCancellable>()
    
    //Intermidiar variables to connect conductor parts and interface
    let partFeedback: PartFeedback
    //Local state vars
    @Published var partFeedbackState: PartFeedbackState
    //Higher up databse for all changed values in playView / editView
    @Binding var setSettings: SetSettings
        
    init(
        playViewState: PlayViewState,
        conductor: Conductor,
        imageDifference: Binding<ImageDifference>,
        leveling: Leveling,
        setSettings: Binding<SetSettings>,
        
        partFeedback: PartFeedback,
        partFeedbackState: PartFeedbackState,
        
        feedbackObjectsSate: FeedbackObjectsState
    ) {
        self.playViewState = playViewState
        self.conductor = conductor
        self._imageDifference = imageDifference
        self.leveling = leveling
        self._setSettings = setSettings
        
        self.partFeedback = partFeedback
        self.partFeedbackState = partFeedbackState
        
        frameExtractor = FrameExtractor.shared
        frameExtractor.delegate = self
        
        startObservingData()
    }
    
    /*
     
    Here we find the big level changer
     
     */
    func startObservingData() {
        
        //Levels
        self.leveling.currentSetLevelSubject.sink { value in
            
//            print("startObservingData value: \(value)")
            
            let oldLevel = Int(self.playViewState.currentLevel)
            self.playViewState.currentLevel = value
            let currentLevel = Int(self.playViewState.currentLevel)
            
            //On level change mute and un-mute tracks accordingly
            if oldLevel != currentLevel {
                                
                self.conductor.trackMuteAndClipStatusPerLevelControl(
                    level: Int(currentLevel),
                    setSettings: self.setSettings,
                    from: "levelChange"
                )
            }
            
//            TODO: Why is amount of levels not consistent within a set?
//            print("Aantal levels: \(self.playViewState.currentInstrumentsSet.levelInstruments.count)")
//
//            //Start over at the end!
//            if currentLevel > self.playViewState.currentInstrumentsSet.levelInstruments.count {
//                self.leveling.currentSetLevelSubject.send(0)
//            }
        }
        .store(in: &cancellables)
        
        //Image difference values
        self.imageDifference.values.sink { values in
            
            guard self.conductor.isConductorPlayingSubject.value else { return }
            
            DispatchQueue.main.sync { [weak self] in
                
                self?.playViewState.values = values
                
                let levelValue = self?.conductor.valuesDidChange(
                    //These are the main values for controlling
                    values: values,
                    //Dynamic area's of interest
                    setSettings: self!.setSettings,
                    //These 3 are for advanced view monitoring
                    currentSetLevel: self?.leveling.currentSetLevelSubject.value ?? 0,
                    partFeedbackTrackID: self?.partFeedback.currentTrackID.value ?? "",
                    partFeedbackPartID: self?.partFeedback.currentPartID.value ?? ""
                )
                
                if self?.leveling.pauseLevel == false {
                    self?.leveling.currentSetLevelSubject.send(levelValue ?? 0)
                }
            }
        }
        .store(in: &cancellables)
        
        //Intermediair for part value monitoring preview        
        self.conductor.forwardRampedPartFeedback.sink { value in
            self.partFeedbackState.ramped = Double(value)
        }
        .store(in: &cancellables)
    }
    
    func tapMediaControlButton() {
        
        leveling.pauseLevel = conductor.isConductorPlayingSubject.value
        
        if self.conductor.isConductorPlayingSubject.value {
            self.frameExtractor.stopExtracting()
            self.frameExtractor.startExtracting()
        }

        conductor.togglePlayEngineAndTracks(
            currentSetLevel: leveling.currentSetLevelSubject.value,
            setSettings: self.setSettings
        )
    }
    
    func controlsViewAction(action: PlayerControlsViewAction) {
        switch action {
        case .displayModeChange(let displayModes):
            playViewState.displayMode = displayModes
        case .settingsChange(let value):
            playViewState.buildSettings.isAdvanced = value
        case .partFeedbackViewChange(let value):
            playViewState.buildSettings.instrumentPartEditor = value
        case .masterTrackViewChange(let value):
            playViewState.buildSettings.isMasterTrack = value
        }
    }
    
    //PlayGridView Get colors per track, ColorTypes make iterating in a SwiftUI View possible
    func colorsPerTrack(row: Int, column: Int, currentLevel: Int) -> [ColorType] {
        
        var colors: [ColorType] = []
        
        for settingsTrack in setSettings.tracks {
            
            if settingsTrack.value.levels.contains(currentLevel){
                
                let trackColor = settingsTrack.value.instrumentColor
                
                for setPart in settingsTrack.value.parts {
                    
                    //FIXME: add currentLevel
                    if !setPart.value.dontDrawVisual {
                        
                        if setPart.value.isIndexSelected(
                            row: row,
                            column: column,
                            gridRows: setSettings.gridRows,
                            gridColumns: setSettings.gridColumns){
                            
                            colors.append(ColorType(color: trackColor))
                        }
                    }
                }
            }
        }
        
        return colors.isEmpty ? [ColorType(color: .black.opacity(0.01))] : colors
    }
    
    //PlayGridView AlL Track / Part colors at correct Indexes
    public func colorTypes(row: Int, column: Int) -> [ColorType] {
        
        let colors = colorsPerTrack(
            row: row, column: column, currentLevel: Int( self.leveling.currentSetLevelSubject.value )
        )
        
        guard conductor.isConductorPlayingSubject.value else { return colors }
        
        if row < self.playViewState.values.count {
            if column < self.playViewState.values[row].count {
                return colors.map {
                    ColorType(color: $0.color.opacity(CGFloat(self.playViewState.values[row][column].scaledValue)))
                }
            }
        }
        return colors
    }
    
    //EditGridView get color for edit selected part
    public func partColor(row: Int, column: Int) -> Color {
        
        let trackId = self.partFeedback.currentTrackID.value
        
        if trackId == "" {
//            print("partColor: No track selected")
            return .black.opacity(0.01)
        }
        
        let partId = self.partFeedback.currentPartID.value
        
        if partId == "" {
//            print("partColor: No part selected")
            return .black.opacity(0.01)
        }
        
        let index: Int = row * setSettings.gridColumns + column
        
        let color = setSettings.tracks[trackId]?.parts[partId]?.areaOfInterestColor[index] ?? .red
        
        return color
    }
    
    public func partDegree(row: Int, column: Int) -> Double {

        let trackId = self.partFeedback.currentTrackID.value
        if trackId == "" {
//            print("partDegree: No track selected")
            return 0
        }

        let partId = self.partFeedback.currentPartID.value
        if partId == "" {
//            print("partDegree: No part selected")
            return 0
        }

        if setSettings.tracks[trackId]?.parts[partId]?.partNumber == 1 {
            return 25
        }
        else if setSettings.tracks[trackId]?.parts[partId]?.partNumber == 2 {
            return -25
        }

        return 0
    }
    
    //EditGridView tap on cell to toggle its status
    public func tapOnCell(row: Int, column: Int){
        
        let trackId = self.partFeedback.currentTrackID.value
        if trackId == "" {
            print("tapOnCell No track selected")
            return
        }
        
        let partId = self.partFeedback.currentPartID.value
        if partId == "" {
            print("tapOnCell No part selected")
            return
        }
        
        let index: Int = row * setSettings.gridColumns + column
        
        if self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] == 1 {
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] = 0
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterestColor[index] = .white.opacity(0.01)
        }
        else {
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] = 1
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterestColor[index] = self.setSettings.tracks[trackId]!.instrumentColor
        }
        
        //Update this var to update View
        self.playViewState.updateEditView += 1
    }
}

extension PlayViewModel: FrameExtractorDelegate {
    
    func captured(image: CIImage) {
        guard conductor.isConductorPlayingSubject.value else { return }
        imageDifference.updateImageData(image: image)
    }
    
}

