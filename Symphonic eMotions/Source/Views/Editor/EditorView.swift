//
//  EditorView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2023.
//

import SwiftUI

struct EditorView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    
    @State var showEditorPart: EditorParts = .none
    
    //Set
    @State var numberOfTracks: Int
    @State var editorParts: [EditorParts]
    
    //Levels
    @State var trackLevels: [String: [Int]]
    @State var noteNumbersLevels: [String: [Int]]
    @State var midiClipsLevels: [String: [Int]]
    
    //Position
    @State var gridRow: Int
    @State var noteNumbersPositions: [String: [Int]]
    @State var midiClipPositions: [String: [Int]]
    
    //Note numbers per track
    @State var noteNumbers: [String: [Int]]
    @State var noteNumberLetters: [String: [Int]]
    
    //Midi cips per track
    @State var midiClips: [String: [Double]]
    @State var midiClipLetters: [String: [Int]]
    
    //Types per track
    @State var noteSources: [String: NoteSource]
    @State var startTypes: [String: StartType]
    @State var variationTypes: [String: VariationType]
    @State var availableVariationTypes: [String: [VariationType]]
    @State var instrumentTypes: [String: InstrumentsSet.Track.InstrumentType]
    
    //TODO: 
    //waveRange
    //instrumentPreset
    //instrumentMidiFile
    //instrumentAudioFiles
    
    //Part variables
    @State var areaOfInterest: [String: [Int]]
    @State var minimalLevel: [String: Double]
    
    let columnWidth: CGFloat = 150
    let headingSize: CGFloat = 20
    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>
    ) {
        self.setInfoModel = setInfoModel
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
        _showEditorPart = State(initialValue: .none)
        
        var numberOfTracks = Int()
        var editorParts = [EditorParts]()
        
        var trackLevelsInit = [String: [Int]]()
        var noteNumbersLevelsInit = [String: [Int]]()
        var midiClipsLevelsInit = [String: [Int]]()
        
        var noteNumbersPositionsInit = [String: [Int]]()
        var midiClipPositionsInit = [String: [Int]]()
        
        var noteNumbersInit = [String: [Int]]()
        var noteNumberLettersInit = [String: [Int]]()
        
        var midiClipsInit = [String: [Double]]()
        var midiClipLettersInit = [String: [Int]]()
        
        var noteSourcesInit = [String: NoteSource]()
        var startTypesInit = [String: StartType]()
        var variationTypesInit = [String: VariationType]()
        var availableVariationTypesInit = [String: [VariationType]]()
        
        var instrumentTypesInit = [String: InstrumentsSet.Track.InstrumentType]()
        
        var areaOfInterestInit = [String: [Int]]()
        var minimalLevelInit = [String: Double]()
        
        //Loop over tracks once
        for track in setInfoModel.setSettings.tracks {
            
            let levels = track.value.levels
            trackLevelsInit[track.value.trackId] = levels
            
            let noteLevels = track.value.notesToLevel
            noteNumbersLevelsInit[track.value.trackId] = noteLevels
            
            let midiLevels = track.value.loopsToLevel
            midiClipsLevelsInit[track.value.trackId] = midiLevels
            
            let notePosition = track.value.notesToGrid
            noteNumbersPositionsInit[track.value.trackId] = notePosition
            
            let midiPosition = track.value.loopsToGrid
            midiClipPositionsInit[track.value.trackId] = midiPosition
            
            let noteNumber = track.value.midiGroup
            noteNumbersInit[track.value.trackId] = noteNumber
            
            let nclips = track.value.midiGroup
            noteNumberLettersInit[track.value.trackId] = Array(0..<nclips.count).map{$0}
            
            let midiClip = track.value.loopLength
            midiClipsInit[track.value.trackId] = midiClip
            
            let mclips = track.value.loopLength
            midiClipLettersInit[track.value.trackId] = Array(0..<mclips.count).map{$0}
            
            let noteSource = track.value.noteSource
            noteSourcesInit[track.value.trackId] = noteSource
            
            let startType = track.value.startType
            startTypesInit[track.value.trackId] = startType
            
            let variation = track.value.variationType
            variationTypesInit[track.value.trackId] = variation
            
            if noteSource == .midiFile {
                availableVariationTypesInit[track.value.trackId] = [
                    .variationByLevel,
                    .variationByPosition
                ]
            }
            //Note numbers
            else{
                availableVariationTypesInit[track.value.trackId] = [
                    .variationByLevel,
                    .variationByPosition,
                    .variationSequencial
                ]
            }
            
            let instrumentType = track.value.instrumentType
            instrumentTypesInit[track.value.trackId] = instrumentType
                
            for part in track.value.parts {
                areaOfInterestInit[part.value.partId] = part.value.areaOfInterest
                minimalLevelInit[part.value.partId] = part.value.minimalLevel
            }
        }
        
        _numberOfTracks = State(initialValue: setInfoModel.setSettings.tracks.count)
        _editorParts = State(initialValue: setInfoModel.selectableEditorParts())
        _trackLevels = State(initialValue: trackLevelsInit)
        _noteNumbersLevels = State(initialValue: noteNumbersLevelsInit)
        _midiClipsLevels = State(initialValue: midiClipsLevelsInit)
        _gridRow = State(initialValue: setInfoModel.setSettings.gridRows)
        _noteNumbersPositions = State(initialValue: noteNumbersPositionsInit)
        _midiClipPositions = State(initialValue: midiClipPositionsInit)
        _noteNumbers = State(initialValue: noteNumbersInit)
        _noteNumberLetters = State(initialValue: noteNumberLettersInit)
        _midiClips = State(initialValue: midiClipsInit)
        _midiClipLetters = State(initialValue: midiClipLettersInit)
        _noteSources = State(initialValue: noteSourcesInit)
        _startTypes = State(initialValue: startTypesInit)
        _variationTypes = State(initialValue: variationTypesInit)
        _availableVariationTypes = State(initialValue: availableVariationTypesInit)
        _instrumentTypes = State(initialValue: instrumentTypesInit)
        _areaOfInterest = State(initialValue: areaOfInterestInit)
        _minimalLevel = State(initialValue: minimalLevelInit)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            SetEditorView(
                setInfoModel: setInfoModel,
                editorParts: $editorParts,
                showEditorPart: $showEditorPart,
                trackLevels: $trackLevels,
                noteNumbersLevels: $noteNumbersLevels,
                midiClipsLevels: $midiClipsLevels,
                gridRow: $gridRow,
                noteNumbersPositions: $noteNumbersPositions,
                midiClipPositions: $midiClipPositions
            )
            ScrollView{
                TrackEditorView(
                    setInfoModel: setInfoModel,
                    editorParts: $editorParts,
                    showEditorPart: $showEditorPart,
                    numberOfTracks: $numberOfTracks,
                    trackLevels: $trackLevels,
                    noteNumbersLevels: $noteNumbersLevels,
                    midiClipsLevels: $midiClipsLevels,
                    gridRow: $gridRow,
                    noteNumbersPositions: $noteNumbersPositions,
                    midiClipPositions: $midiClipPositions,
                    noteNumbers: $noteNumbers,
                    noteNumberLetters: $noteNumberLetters,
                    midiClips: $midiClips,
                    midiClipLetters: $midiClipLetters,
                    noteSources: $noteSources,
                    startTypes: $startTypes,
                    variationTypes: $variationTypes,
                    availableVariationTypes: $availableVariationTypes,
                    instrumentTypes: $instrumentTypes,
                    areaOfInterest: $areaOfInterest,
                    minimalLevel: $minimalLevel
                )
            }
        }
        
        //Cancel, New set, Save buttons
        HStack {
            
            EMButton(
                action: {
                    //Change the View
                    if sessionDisplaySub == .playListEditor {
                        sessionDisplay = .playlists
                        sessionDisplaySub = .playlists
                    }
                    else{
                        sessionDisplay = .setInfo
                        sessionDisplaySub = .none
                    }
                }, color: .blue, isSolid: true, maxWidth: 130, height: 35
            ){ Text(NSLocalizedString("Cancel", comment: "")) }
            .frame(width: 130)
            .padding(.trailing)
            
            EMButton(
                action: {
                    let fileName = AppUtils.createWorkingFile(
                        setSettings: setInfoModel.setSettings,
                        instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                        duplicateLastTrack: false,
                        asNewFile: true
                    )
                    fileController.addSetFileURLToController(fileName: fileName)
                    
                    //Change the View
                    if sessionDisplaySub == .playListEditor {
                        sessionDisplay = .playlists
                        sessionDisplaySub = .playlists
                    }
                    else{
                        sessionDisplay = .setInfo
                        sessionDisplaySub = .none
                    }
                    
                }, color: .orange, isSolid: true, maxWidth: 130, height: 35
            ){ Text(NSLocalizedString("New set", comment: "")) }
            .frame(width: 130)
            .padding(.leading)
            
            //This editor is unreachable for editing Bundle files, so no optional save button
            EMButton(
                action: {
                    
                    let fileName = AppUtils.createWorkingFile(
                        setSettings: setInfoModel.setSettings,
                        instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                        duplicateLastTrack: false,
                        asNewFile: false
                    )
                    fileController.addSetFileURLToController(fileName: fileName)
                    
                    //Figure out if we opened from playlists
                    let parentDirectoryName = setInfoModel.setSettings.setURL.deletingLastPathComponent().lastPathComponent
                    
                    //Change the View (this check is doubled in createWorkingFile)
                    if BuildSettings.Playlists(rawValue: parentDirectoryName) != nil {
                        sessionDisplay = .playlists
                        sessionDisplaySub = .playlists
                    } else {
                        sessionDisplay = .setInfo
                        sessionDisplaySub = .none
                    }
                    
                }, color: .red, isSolid: true, maxWidth: 130, height: 35
            ){ Text(NSLocalizedString("Save", comment: "")) }
            .frame(width: 130)
            
            
            
        }
        .padding()
        
//        Text("Editing: \(setInfoModel.setSettings.setURL)")
    }
}
