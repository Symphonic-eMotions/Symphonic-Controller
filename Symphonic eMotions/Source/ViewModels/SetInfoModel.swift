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
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    
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
        
        subscribeToLevels()
        subscribeToImageDifference()
        subscribeToPartFeedback()
    }
    
    func subscribeToLevels() {
        cancellableLevels?.cancel()
        //Reset to prevend memory leak
        cancellableLevels = nil
        cancellableLevels = self.leveling.currentSetLevelSubject.sink { [weak self] value in
            
            guard let self = self else { return }

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
                
                if(currentLevel == setSettings.levels.count) {
                    
                    //Stop engine
                    conductor.pauzeEngineAndStopTracks(
                        setSettings: setSettings,
                        resetLevels: true
                    )
                    isSetPlaying = false
                    //Engine is of, reset to level 0
                    leveling.currentSetLevelSubject.send(0)
                }
            }
        }
    }
    
    func subscribeToImageDifference() {
        
        cancellableImageDifference?.cancel()
        cancellableImageDifference = nil
        
        cancellableImageDifference = self.imageDifference.values.sink { [weak self] values in
            
            guard let self = self else { return }

            DispatchQueue.main.async {
                
                self.setInfoState.values = values
                
                let levelValue = self.conductor.valuesDidChange(
                    // These are the main values for controlling
                    values: values,
                    // Dynamic area's of interest
                    setSettings: self.setSettings,
                    // These 3 are for advanced view monitoring
                    currentSetLevel: self.leveling.currentSetLevelSubject.value,
                    partFeedbackTrackID: self.partFeedback.currentTrackID.value,
                    partFeedbackPartID: self.partFeedback.currentPartID.value
                )
                
                if self.leveling.pauseLevel == false {
                    let newLevel = levelValue
                    let currentLevel = self.leveling.currentSetLevelSubject.value
                    if newLevel != currentLevel {
                        self.leveling.currentSetLevelSubject.send(newLevel)
                    }
                }
            }
        }
    }
    
    func subscribeToPartFeedback() {
        
        cancellablePartFeddback?.cancel()
        cancellablePartFeddback = nil
        
        cancellablePartFeddback = self.conductor.forwardRampedPartFeedback.sink { [weak self] value in
            guard let self = self else { return }
            self.partFeedbackState.ramped = Double(value)
        }
    }
    
    let feedbackPresets: [(button: Int, feedback: Double)] = [
        (0, 0.70), // Meeste feedback
        (1, 0.60),
        (2, 0.50),
        (3, 0.40)  // Minste feedback
    ]
    
    func buttonToFeedback(id: Int) -> Double {
        for preset in feedbackPresets {
            if preset.button == id {
                return preset.feedback
            }
        }
        return 0.5
    }

    func feedbackToButton(feedback: Double) -> Int {
        for preset in feedbackPresets {
            if preset.feedback == feedback {
                return preset.button
            }
        }
        return 1
    }
    
    let sensitivityPreset: [(button: Int, sensitivity: Double)] = [
        (0, 0.70), // Minste gevoeligheid
        (1, 0.80),
        (2, 0.90),
        (3, 0.95)  // Meeste gevoeligheid
    ]
    
    func buttonToSensitivity(id: Int) -> Double {
        for preset in sensitivityPreset {
            if preset.button == id {
                return preset.sensitivity
            }
        }
        return 0.5
    }
    
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
            partName: "Low pass filter",
            partNumber: 1,
            rampUp: newNodeSetting.rampSpeed!,
            rampDown: newNodeSetting.rampSpeedDown!,
            minimalLevel: newNodeSetting.minimalLevel!,
            areaOfInterest: Array(repeating: 1, count: cells),
            areaOfInterestColor: Array(repeating: Color("InstrumentColor000"), count: cells),
            damperTarget: newDamperTarget,
            dontDrawVisual: false,
            dampMode: .easeInCubic,
            targetType: .effect,
            targetNameEffect: .lowPassFilter,
            targetParameterEffect: .cutoffFrequency,
            targetParameterInstrument: "samplerCC9",
            targetParameterSequencer: "velocity"
            
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
                dontDrawVisual: false,
                dampMode: .easeInCubic,
                targetType: .sequencer,
                targetNameEffect: .lowPassFilter,
                targetParameterEffect: .cutoffFrequency,
                targetParameterInstrument: "samplerCC9",
                targetParameterSequencer: "velocity"
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
            return .black.opacity(0.01)
        }
        
        let partId = self.partFeedback.currentPartID.value
        
        if partId == "" {
            return .black.opacity(0.01)
        }
        
        let index: Int = row * setSettings.gridColumns + column
        
        let color = setSettings.tracks[trackId]?.parts[partId]?.areaOfInterestColor[index] ?? .red
        
        return color
    }
    
    public func partDegree(row: Int, column: Int) -> Double {

        let trackId = self.partFeedback.currentTrackID.value
        if trackId == "" {
            return 0
        }

        let partId = self.partFeedback.currentPartID.value
        if partId == "" {
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
        
        guard isSetPlaying else { return colors }
        
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
        guard isSetPlaying else { return }
        imageDifference.updateImageData(image: image)
    }
}
