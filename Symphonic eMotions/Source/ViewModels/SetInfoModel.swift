//
//  SetInfoModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI
import Combine
import OrderedCollections

struct SetInfoState {
    var currentInstrumentsSet: InstrumentsSet
    var currentLevel: Double = 0.0 //Leveling
    var values: [[AreaValues]] = []
    //SpriteKit
    var displayOpacity: Float = 0.12
    //Pro
    var buildSettings: BuildSettings
    var displayMode: DisplayModes = .both
    //Part editor
    var updateEditView: Int = 0
    //Master
    var masterTrackStructure: [MasterTrackEffect]?
}

enum PlayerControlsViewAction {
    case displayModeChange(DisplayModes)
    case settingsChange(Bool)
    case partFeedbackViewChange(Bool)
    case masterTrackViewChange(Bool)
}

final class SetInfoModel: ObservableObject {
    
    private(set) var frameExtractor: FrameExtractor
    @Binding var setInfoLocalState: SetInfoLocalState
    @Binding var setSettings: SetSettings
    @Binding var imageDifference: ImageDifference
    @Published var setInfoState: SetInfoState
    let currentInstrumentsSetIsChanged: (InstrumentsSet) -> ()
    var conductor: Conductor
    let leveling: Leveling
    
    let partFeedback: PartFeedback
    @Published var partFeedbackState: PartFeedbackState
    let playerControlsAction: ((PlayerControlsViewAction) -> Void)?
    
//    var cancellablesLevels = Swift.Set<AnyCancellable>()
//    var cancellablesImageDifference = Swift.Set<AnyCancellable>()
//    var cancellablesPartFeedback = Swift.Set<AnyCancellable>()
    
    private var cancellableLevels: AnyCancellable? = nil
    private var cancellableImageDifference: AnyCancellable? = nil
    private var cancellablePartFeddback: AnyCancellable? = nil
    
    
    init(
        setInfoLocalState: Binding<SetInfoLocalState>,
        setSettings: Binding<SetSettings>,
        imageDifference: Binding<ImageDifference>,
        setInfoState: SetInfoState,
        currentInstrumentsSetIsChanged: @escaping (InstrumentsSet) -> Void,
        conductor: Conductor,
        leveling: Leveling,
        partFeedback: PartFeedback,
        partFeedbackState: PartFeedbackState,
        playerControlsAction: ((PlayerControlsViewAction) -> Void)? = nil
    ) {
        self._setInfoLocalState = setInfoLocalState
        self._setSettings = setSettings
        self._imageDifference = imageDifference
        self.setInfoState = setInfoState
        self.currentInstrumentsSetIsChanged = currentInstrumentsSetIsChanged
        self.conductor = conductor
        self.leveling = leveling
        
        self.partFeedback = partFeedback
        self.partFeedbackState = partFeedbackState
        
        self.playerControlsAction = playerControlsAction
        
        frameExtractor = FrameExtractor.shared
        frameExtractor.delegate = self
        
        startObservingData()
    }
    
    
    func movementSetting(id: Int) -> Double{
        
        let feedbackPresets: [Int:Double] = [
            0: 0.7,
            1: 0.5,
            2: 0.3,
            3: 0.1
        ]
        if let presetValue = feedbackPresets[id] {
            print("Set feedback based on table \(id) is feedback \(feedbackPresets)")
            return presetValue
        }
        else{
            return 0.5
        }
    }
    
    func startObservingData() {
        
        print("startObservingData subscription")
        
        cancellableLevels?.cancel()
        
        //Levels
        cancellableLevels = self.leveling.currentSetLevelSubject.sink { value in
            
            let oldLevel = Int(self.setInfoState.currentLevel)
            self.setInfoState.currentLevel = value
            let currentLevel = Int(self.setInfoState.currentLevel)

            //On level change mute and un-mute tracks accordingly
            if oldLevel != currentLevel {
                print("SINK LEVEL CHANGE \(oldLevel) ---> \(currentLevel)")

                //Mute and unmutes tracks to level settings
                //
                // Switch View logic sits in MainView / PlayView.onReceive
                //
                self.conductor.levelController(
                    level: Int(currentLevel),
                    setSettings: self.setSettings
                )
            }
        }
        
        cancellableImageDifference?.cancel()
        
        cancellableImageDifference = self.imageDifference.values.sink { [weak self] values in
        
            guard self!.conductor.isConductorPlayingSubject.value else { return }
            
            DispatchQueue.main.async {
            
                self?.setInfoState.values = values
                
//                let levelValue = self?.conductor.valuesDidSetInfoChanged(
//                    //These are the main values for controlling
//                    values: values,
//                    //Dynamic area's of interest
//                    setSettings: self!.setSettings,
//                    //These 3 are for advanced view monitoring
//                    currentSetLevel: self?.leveling.currentSetLevelSubject.value ?? 0
//                )
                
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
//                    self?.leveling.currentSetLevelSubject.send(levelValue ?? 0)
                    let newLevel = levelValue ?? 0
                    let currentLevel = self?.leveling.currentSetLevelSubject.value ?? 0
                    if newLevel != currentLevel {
                        self?.leveling.currentSetLevelSubject.send(newLevel)
                    }
                }
            }
        }
        
        cancellablePartFeddback?.cancel()
        
        //Intermediair for part value monitoring preview
        cancellablePartFeddback = self.conductor.forwardRampedPartFeedback.sink { value in
            
            self.partFeedbackState.ramped = Double(value)
        }
    }
    
    func tapToggleConductor() {
        
        //fix for system stop after 12 set changes
        //If you remove this, video won't be passed through after 12 set changes
        if self.conductor.isConductorPlayingSubject.value {
            self.frameExtractor.stopExtracting()
            self.frameExtractor.startExtracting()
        }

        conductor.togglePlayEngineAndTracks(
            currentSetLevel: leveling.currentSetLevelSubject.value,
            setSettings: self.setSettings
        )
    }
    
    func tapStopAudioEngine(){
        
        conductor.pauzeEngineAndStopTracks(setSettings: self.setSettings)
    }
    
//    func tapMediaControlButton() {
//
//        print("OnTapMediaControlButton")
//
//        //fix for system stop after 12 set changes
//        //If you remove this, video won't be passed through after 12 set changes
//        if self.conductor.isConductorPlayingSubject.value {
//            self.frameExtractor.stopExtracting()
//            self.frameExtractor.startExtracting()
//
//            stopObservingData()
//        }
//        else{
//            keepOneRunning()
//        }
//
//        conductor.togglePlayEngineAndTracks(
//            currentSetLevel: leveling.currentSetLevelSubject.value,
//            setSettings: self.setSettings
//        )
//    }
    
    func selectableEditorParts() -> [EditorParts] {
        var selectableEditorParts: [EditorParts] = [.none,.set,.levels,.source,.start,.variation,.location]
        
        for track in setSettings.tracks {
            let trackIndex = track.value.trackIndex
            let enumFromString = EditorParts(rawValue: "track\(trackIndex)")
            selectableEditorParts.append(enumFromString ?? .none)
        }
        
        return selectableEditorParts
    }
    
    func addTrack() -> TrackSettings? {
        
        //New track
        var trackId = "New track \(self.setSettings.tracks.count + 1)"
        var nameExists = true
        var counter = 0
        while nameExists {
            if let _ = self.setSettings.tracks[trackId] {
                // Track name already exists, modify the trackId
                counter += 1
                trackId = "New track \(self.setSettings.tracks.count + counter)"
            } else {
                // Track name doesn't exist, break the loop
                nameExists = false
            }
        }
        
        //New part
        let partId: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        //Amount of cells in grid
        let cells = self.setSettings.gridRows * self.setSettings.gridColumns
        //Defaut midi note number
        let noteNumber: Int = 48
        
        //New nodeSetting
        let newNodeSetting = InstrumentsSet.Track.Part.DamperTarget.NodeSettings(
            minimalLevel: 0.1,
            rampSpeed: 0.15,
            rampSpeedDown: 0.14
        )
        
        //New damperTarget
        let newDamperTarget = InstrumentsSet.Track.Part.DamperTarget(
            trackId: trackId,
            nodeType: .sequencer,
            nodeName: "",
            parameter: "velocity",
            parameterRange: [0,1],
            midiData: nil,
            nodeSettings: newNodeSetting,
            dampMode: .easeInCubic
        )
        
        //Calculate number of cells and create new Part
        let newPart = PartSettings(
            partId: partId,
            partName: "Velocity",
            partNumber: 1,
            rampUp: newNodeSetting.rampSpeed!,
            rampDown: newNodeSetting.rampSpeedDown!,
            minimalLevel: newNodeSetting.minimalLevel!,
            areaOfInterest: Array(repeating: 1, count: cells),
            areaOfInterestColor: Array(repeating: Color("InstrumentColor000"), count: cells),
            damperTarget: newDamperTarget,
            dontDrawVisual: false
        )
        
        //Create new Track
        let newTrack = TrackSettings(
            trackId: trackId,
            trackIndex: 0,
            trackName: trackId,
            noteSource: .noteNumbers,
            startType: .oneShot,
            variationType: .variationByPosition,
            instrumentType: .audioBuffer,
            exsFile: ExsFiles(rawValue: "trigger")!,
            audioFiles: [],
            instrumentVolume: 0,
            instrumentColor: Color("InstrumentColor000"),
            midiFile: "trigger",
            midiGroup: [noteNumber],
            notesToGrid: Array(repeating: noteNumber, count: cells),
            notesToGridMapped: AppUtils.areaOfInterestGridMapped(
                areaOfInterest: Array(repeating: 1, count: cells),
                cellsToGrid: Array(repeating: noteNumber, count: cells)
            ),
            notesToLevel: Array(repeating: noteNumber, count: self.setSettings.levels.count),
            noteNumbersClips: [],
            notesSequenceType: .nextForward,
            loopLength: [16],
            loopsToLevel: [],
            loopsToGrid: [],
            loopsToGridMapped: [],
            levels: (0...self.setSettings.levels.count-1).map { $0 },
            parts: [partId: newPart]
        )
        
        return newTrack
    }
    
    func addVelocityPart(velocitySensitive: Bool, trackId: String) -> PartSettings? {
        
        var returnPart: PartSettings?
        
        let numberOfParts = self.setSettings.tracks[trackId]?.parts.count ?? 0
        
        if velocitySensitive {
            
            //add velocity part
            let partId: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            
            let newNodeSetting = InstrumentsSet.Track.Part.DamperTarget.NodeSettings(
                minimalLevel: 0.1,
                rampSpeed: 0.15,
                rampSpeedDown: 0.14
            )
            
            let newDamperTarget = InstrumentsSet.Track.Part.DamperTarget(
                trackId: trackId,
                nodeType: .sequencer,
                nodeName: "",
                parameter: "velocity",
                parameterRange: [0,1],
                midiData: nil,
                nodeSettings: newNodeSetting,
                dampMode: .easeInCubic
            )
            
            let cells = self.setSettings.gridRows * self.setSettings.gridColumns
            
            let newPart = PartSettings(
                partId: partId,
                partName: "Velocity",
                partNumber: numberOfParts + 1,
                rampUp: newNodeSetting.rampSpeed!,
                rampDown: newNodeSetting.rampSpeedDown!,
                minimalLevel: newNodeSetting.minimalLevel!,
                areaOfInterest: Array(repeating: 1, count: cells),
                areaOfInterestColor: Array(repeating: Color("InstrumentColor000"), count: cells),
                damperTarget: newDamperTarget,
                dontDrawVisual: false
            )
            
            returnPart = newPart
        }
        //
//        else{
//            
//            if numberOfParts > 1 {
//                
//                if let track = self.setSettings.tracks[trackId] {
//                    
//                    var updatedParts = OrderedDictionary<String, PartSettings>()
//                    for (partId, part) in track.parts {
//                        if part.damperTarget.parameter != "velocity" {
//                            updatedParts[partId] = part
//                        }
//                    }
//                    self.setSettings.tracks[trackId]?.parts = updatedParts
//                }
//            }
//        }
        
        return returnPart
    }
    
    func trackNames() -> [String: String] {
        var trackNames: [String: String] = [:]
        for track in setSettings.tracks {
            //translate EditorPart track name by its enum case (i.e. track15)
            trackNames["track\(track.value.trackIndex)"] = track.value.trackName
        }
        return trackNames
    }
    
    func tapSetRow(filePath: String) {
        
        let instrumentSet = AppUtils.loadInstrumentSet(json: filePath)
        currentInstrumentsSetIsChanged(instrumentSet)
    }
    
    func tapSavedRow(fileName: String) {
                
        let instrumentSet = AppUtils.loadSavedInstrumentSet(fileName: fileName)
        currentInstrumentsSetIsChanged(instrumentSet!)
    }

    func reloadSet(fileName: String) {
                
        let instrumentSet = AppUtils.loadSavedInstrumentSet(fileName: fileName)
        currentInstrumentsSetIsChanged(instrumentSet!)
        
        setSettings = AppUtils.setSettings(
            instrumentSet: instrumentSet!
        )
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
    
    func tapSettingsButton() {
        setInfoState.buildSettings.isAdvanced.toggle()
        playerControlsAction?(.settingsChange(setInfoState.buildSettings.isAdvanced))
    }
    
    func tapMasterFxButton() {
        setInfoState.buildSettings.isMasterTrack.toggle()
        playerControlsAction?(.masterTrackViewChange(setInfoState.buildSettings.isMasterTrack))
    }
    
    func tapPartFeedbackButton() {
        setInfoState.buildSettings.instrumentPartEditor.toggle()
        playerControlsAction?(.partFeedbackViewChange(setInfoState.buildSettings.instrumentPartEditor))
    }
    
    func tapSetTempoBPMPlus(){
        self.setSettings.bpm -= 1
    }
    
    func tapSetTempoBPMMin(){
        self.setSettings.bpm += 1
    }
    
    func tapSetTempoReset(){
        
        let tempo = self.conductor.resetTempo()
        self.setSettings.bpm = tempo
    }
    
    func scale(
        input: Double,
        fromInputRange: (Double, Double),
        toOutputRange: (Double, Double)) -> Double {
        let (A, B) = fromInputRange
        let (C, D) = toOutputRange
        
        // Translate the input range to [0, 1]
        let normalizedInput = (input - A) / (B - A)
        
        // Translate from [0, 1] to the output range
        let output = C + (D - C) * normalizedInput
        
        return output
    }
    
    
    
    
    
    //Part editor
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
        
        //Update areaOfInterest and areaOfInterestColor for storage
        if self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] == 1 {
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] = 0
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterestColor[index] = .white.opacity(0.01)
        }
        else {
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest[index] = 1
            self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterestColor[index] = self.setSettings.tracks[trackId]!.instrumentColor
        }
        
        //Get new connection with clip positions
        self.setSettings.tracks[trackId]!.loopsToGridMapped = AppUtils.areaOfInterestGridMapped(
            areaOfInterest: self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest,
            cellsToGrid: self.setSettings.tracks[trackId]!.loopsToGrid)
        
        //Get new connections with note positions
        self.setSettings.tracks[trackId]!.notesToGridMapped = AppUtils.areaOfInterestGridMapped(
            areaOfInterest: self.setSettings.tracks[trackId]!.parts[partId]!.areaOfInterest,
            cellsToGrid: self.setSettings.tracks[trackId]!.notesToGrid)
        
        //Update this var to update View
        self.setInfoState.updateEditView += 1
    }

    //PlayGridView AlL Track / Part colors at correct Indexes
    public func colorTypes(row: Int, column: Int) -> [ColorType] {
        
        let colors = colorsPerTrack(
            row: row, column: column, currentLevel: Int( self.leveling.currentSetLevelSubject.value )
        )
        
        guard conductor.isConductorPlayingSubject.value else { return colors }
        
        if row < self.setInfoState.values.count {
            if column < self.setInfoState.values[row].count {
                return colors.map {
                    ColorType(color: $0.color.opacity(CGFloat(self.setInfoState.values[row][column].scaledValue)))
                }
            }
        }
        return colors
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
}

extension SetInfoModel: FrameExtractorDelegate {
    
    func captured(image: CIImage) {
        guard conductor.isConductorPlayingSubject.value else { return }
        imageDifference.updateImageData(image: image)
    }
}
