//
//  EditorView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2023.
//

import SwiftUI

struct EditorView: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "EditorView"
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    
    //Not working...
    @State var reloadView: Bool = false
    
    //Set
    @State var numberOfTracks: Int
    //What are we editing?
    @State var showEditorPart: EditorParts = .none
    //All editor groups including tracks
    @State var editorParts: [EditorParts]
    
    //Levels
    //!!!trackLevels have JUST the level indexes where yhe track is in!!!!!!!!!!!!!!
    @State var trackLevels: [String: [Int]]
    //Keeps track of the midi index generated within the sequencer
    @State var noteNumbersLevels: [String: [Int]]
    //Same as noteNumbersLevels for midi files in bundle or sandbox
    @State var midiClipsLevels: [String: [Int]]
    
    //Position
    @State var gridRow: Int
    @State var noteNumbersPositions: [String: [Int]]
    @State var midiClipPositions: [String: [Int]]
    
    //Note numbers per track
    @State var noteNumbers: [String: [Int]]
    @State var notesSequenceType: [String: NotesSequenceType]
    //What clips do we have as buffer sanpler audio files
    @State var noteNumbersClips: [String: [Int]]
    
    //Obsolete?
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
    
    //Part variables
    @State var areaOfInterest: [String: [Int]]
    @State var minimalLevel: [String: Double]
    
    @State var dampMode: [String: InstrumentsSet.Track.Part.DamperTarget.DampMode]
    
    //Select Sequencer, Instrument, Effect or Master
    @State private var targetTypes: [String: InstrumentsSet.Track.Part.DamperTarget.NodeType]
    //Effects have names
    @State private var targetNames: [String: InstrumentsSet.Track.Effect.EffectType]
    //One parameter for all types. for effect there's a Type: InstrumentsSet.Track.Effect.EffectKeys
    @State private var targetParameters: [String: String]
    //Inverse values at forwarding (to effect)
    @State private var parametersInversed: [String: Bool]
    
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
        
        var trackLevelsInit = [String: [Int]]()
        var noteNumbersLevelsInit = [String: [Int]]()
        var noteNumbersClipsInit = [String: [Int]]()
        var midiClipsLevelsInit = [String: [Int]]()
        
        var noteNumbersPositionsInit = [String: [Int]]()
        var midiClipPositionsInit = [String: [Int]]()
        
        var noteNumbersInit = [String: [Int]]()
        var notesSequenceTypeInit = [String: NotesSequenceType]()
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
        
        var dampModeInit = [String: InstrumentsSet.Track.Part.DamperTarget.DampMode]()
        var parametersInversedInit = [String: Bool]()
        
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
            
            let noteSequenceType = track.value.notesSequenceType
            notesSequenceTypeInit[track.value.trackId] = noteSequenceType
            
            let midis = track.value.midiGroup
            noteNumberLettersInit[track.value.trackId] = Array(0..<midis.count).map{$0}
            
            let midiClip = track.value.loopLength
            midiClipsInit[track.value.trackId] = midiClip
            
            let mclips = track.value.loopLength
            midiClipLettersInit[track.value.trackId] = Array(0..<mclips.count).map{$0}
            
            let nnClips = track.value.noteNumbersClips
            noteNumbersClipsInit[track.value.trackId] = nnClips
            
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
            
            //Just the parts from current track
            for part in track.value.parts {
                
                areaOfInterestInit[part.value.partId] = part.value.areaOfInterest
                minimalLevelInit[part.value.partId] = part.value.minimalLevel
                dampModeInit[part.value.partId] = part.value.damperTarget.dampMode
                parametersInversedInit[part.value.partId] = part.value.damperTarget.parameterInversed
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
        _notesSequenceType = State(initialValue: notesSequenceTypeInit)
        _noteNumbersClips = State(initialValue: noteNumbersClipsInit)
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
        
        _dampMode = State(initialValue: dampModeInit)
        
        _targetTypes = State(initialValue: [:])
        _targetNames = State(initialValue: [:])
        _targetParameters = State(initialValue: [:])
        _parametersInversed = State(initialValue: parametersInversedInit)
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
                    noteNumbersClips: $noteNumbersClips,
                    midiClipsLevels: $midiClipsLevels,
                    noteNumberLetters: $noteNumberLetters,

                    gridRow: $gridRow,
                    noteNumbersPositions: $noteNumbersPositions,
                    midiClipPositions: $midiClipPositions,

                    noteNumbers: $noteNumbers,
                    notesSequenceType: $notesSequenceType,


                    midiClips: $midiClips,
                    midiClipLetters: $midiClipLetters,

                    noteSources: $noteSources,
                    startTypes: $startTypes,
                    variationTypes: $variationTypes,
                    availableVariationTypes: $availableVariationTypes,
                    instrumentTypes: $instrumentTypes,

                    areaOfInterest: $areaOfInterest,
                    minimalLevel: $minimalLevel,
                    dampMode: $dampMode,
                    targetTypes: $targetTypes,
                    targetNames: $targetNames,
                    targetParameters: $targetParameters,
                    parametersInversed: $parametersInversed
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
                    
                    //Reopen the file
                    setInfoModel.reloadSet(fileName: fileController.urlToFileName(url: URL(currentUrl)))
                    
                    
                    
                    //Figure out if we opened from playlists
                    let parentDirectoryName = setInfoModel.setSettings.setURL.deletingLastPathComponent().lastPathComponent
                    if BuildSettings.Playlists(rawValue: parentDirectoryName) != nil {
                        sessionDisplay = .playlists
                        sessionDisplaySub = .playlists
                    } else {
                        
                        
                        self.reloadView.toggle()
                        
                        showEditorPart = .none
                        
                        sessionDisplaySub = .setInfo
//                        sessionDisplaySub = .none
                    }
                    
                }, color: .red, isSolid: true, maxWidth: 130, height: 35
            ){ Text(NSLocalizedString("Save", comment: "")) }
            .frame(width: 130)
            
            
            
        }
        .padding()
    }
}
