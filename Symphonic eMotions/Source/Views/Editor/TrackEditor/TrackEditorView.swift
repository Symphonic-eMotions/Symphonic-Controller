//
//  TrackEditorView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 15/06/2023.
//

import SwiftUI

struct TrackEditorView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var editorParts: [EditorParts]
    @Binding var showEditorPart: EditorParts
    
    //Set
    @Binding var numberOfTracks: Int
    
    //Levels
    @Binding var trackLevels: [String: [Int]]
    @Binding var noteNumbersLevels: [String: [Int]]
    @Binding var midiClipsLevels: [String: [Int]]
    
    //Position
    @Binding var gridRow: Int
    @Binding var noteNumbersPositions: [String: [Int]]
    @Binding var midiClipPositions: [String: [Int]]
    
    //Note numbers per track
    @Binding var noteNumbers: [String: [Int]]
    @Binding var notesSequenceType: [String: NotesSequenceType]
    //Obsolete?
    @Binding var noteNumberLetters: [String: [Int]]
    
    //Midi cips per track
    @Binding var midiClips: [String: [Double]]
    @Binding var midiClipLetters: [String: [Int]]
    
    //Types per tracks
    @Binding var noteSources: [String: NoteSource]
    @Binding var startTypes: [String: StartType]
    @Binding var variationTypes: [String: VariationType]
    @Binding var availableVariationTypes: [String: [VariationType]]
    @Binding var instrumentTypes: [String: InstrumentsSet.Track.InstrumentType]
    
    //Part variables
    @Binding var areaOfInterest: [String: [Int]]
    @Binding var minimalLevel: [String: Double]
    
    //State
    @State private var showRemoveConfirmation: Bool = false
    @State private var trackKeyToRemove: String? = nil
    @State private var pleaseSave: Bool = false
    
    var body: some View {
        
        //Edit track interface
        VStack(alignment: .leading) {
            
            //Create a clickable row header per track
            ForEach(setInfoModel.setSettings.tracks.keys, id: \.self) { key in
                
                let track = setInfoModel.setSettings.tracks[key]!
                let editorPart = EditorParts(rawValue: "track\(track.trackIndex)")
                
                //Track navigation header
                HStack{
                    Group{
                        Image("track")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .padding(4)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                    }
                    .padding(.leading)
                    
                    if showEditorPart == editorPart {
                        TextField(
                            "Track name",
                            text: Binding(
                                get: { self.setInfoModel.setSettings.tracks[key]?.trackName ?? "" },
                                set: {
                                    if self.setInfoModel.setSettings.tracks[key] != nil {
                                        self.setInfoModel.setSettings.tracks[key]?.trackName = $0
                                    }
                                }
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                        .padding(.trailing)
                        //Exclude TextField from parent onTapGesture
                        .onTapGesture{}
                    }
                    else{
                        Text("\(track.trackName)")
                            .font(.system(size: 20))
                            .padding()
                        
                        Spacer()
                        
                        //Remove track
                        Button("-"){
                            trackKeyToRemove = key
                            showRemoveConfirmation = true
                        }
                        .font(.system(size: 45))
                        .foregroundColor(numberOfTracks == 1 ? .gray : .red)
                        .padding(.trailing)
                        .disabled(numberOfTracks == 1)
                        .alert(isPresented: $showRemoveConfirmation) {
                            Alert(
                                title: Text("Remove track?"),
                                message: Text("Are you sure you want to remove this track?"),
                                primaryButton: .destructive(Text("Remove")) {
                                    //Get the captured track key from @State
                                    if let trackKey = trackKeyToRemove {
                                        //First remove part bindings with track info
                                        let parts = setInfoModel.setSettings.tracks[trackKey]!.parts
                                        for part in parts {
                                            areaOfInterest.removeValue(forKey: part.value.partId)
                                            minimalLevel.removeValue(forKey: part.value.partId)
                                        }
                                        //Mutate struct for writing to file
                                        setInfoModel.setSettings.tracks.removeValue(forKey: trackKey)
                                        //Mutate bindings
                                        trackLevels.removeValue(forKey: trackKey)
                                        noteNumbersLevels.removeValue(forKey: trackKey)
                                        midiClipsLevels.removeValue(forKey: trackKey)
                                        noteNumbersPositions.removeValue(forKey: trackKey)
                                        midiClipPositions.removeValue(forKey: trackKey)
                                        noteNumbers.removeValue(forKey: trackKey)
                                        noteNumberLetters.removeValue(forKey: trackKey)
                                        midiClips.removeValue(forKey: trackKey)
                                        midiClipLetters.removeValue(forKey: trackKey)
                                        noteSources.removeValue(forKey: trackKey)
                                        startTypes.removeValue(forKey: trackKey)
                                        variationTypes.removeValue(forKey: trackKey)
                                        instrumentTypes.removeValue(forKey: trackKey)
                                        
                                        editorParts = setInfoModel.selectableEditorParts()
                                        
                                        numberOfTracks -= 1
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .onTapGesture {
                    withAnimation {
                        if showEditorPart != editorPart {
                            showEditorPart = editorPart ?? .none
                        } else {
                            showEditorPart = .none
                        }
                    }
                }
                
                //If editor parts is selected OR If navigation header is tapped
                if showEditorPart == editorPart || showEditorPart == .levels {
                    
                    InLevelView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        showEditorPart: $showEditorPart,
                        trackLevels: $trackLevels
                    )
                }
                if showEditorPart == editorPart || showEditorPart == .start {
                    
                    StartTypeView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        showEditorPart: $showEditorPart,
                        startTypes: $startTypes
                    )
                }
                if showEditorPart == editorPart || showEditorPart == .sound {
                    
                    SoundSourceView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        showEditorPart: $showEditorPart,
                        soundSources: $instrumentTypes
                    )
                }
                if showEditorPart == editorPart || showEditorPart == .source {
                    
                    NoteSourceView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        showEditorPart: $showEditorPart,
                        noteSources: $noteSources,
                        soundSources: $instrumentTypes,
                        midiClips: $midiClips,
                        midiClipLetters: $midiClipLetters,
                        midiClipsLevels: $midiClipsLevels,
                        midiClipspositions: $midiClipPositions,
                        noteNumbers: $noteNumbers,
                        noteNumberLetters: $noteNumberLetters,
                        availableVariationTypes: $availableVariationTypes
                    )
                }
                
                if showEditorPart == editorPart || showEditorPart == .variation {
                    
                    VariationTypeView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        showEditorPart: $showEditorPart,
                        noteSources: $noteSources,
                        variationTypes: $variationTypes,
                        availableVariationTypes: $availableVariationTypes
                    )
                    
                    if noteSources[key] == .midiFile {
                        
                        if variationTypes[key] == .variationByPosition {
                            
                            MidiClipsPositionsView(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                midiClips: $midiClips,
                                midiClipLetters: $midiClipLetters,
                                midiClipsPositions: $midiClipPositions
                            )
                        }
                        else if variationTypes[key] == .variationByLevel {
                            
                            MidiClipLevelView(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                trackLevels: $trackLevels,
                                midiClips: $midiClips,
                                midiClipLetters: $midiClipLetters,
                                midiClipsLevels: $midiClipsLevels
                            )
                        }
                    }
                    if noteSources[key] == .noteNumbers {
                        
                        if variationTypes[key] == .variationByPosition {
                            NoteNumberPositionsView(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                noteNumbers: $noteNumbers,
                                noteNumbersPositions: $noteNumbersPositions
                            )
                        }
                        else  if variationTypes[key] == .variationByLevel {
                            NoteNumberLevelView(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                trackLevels: $trackLevels,
                                noteNumbersLevels: $noteNumbersLevels,
                                noteNumbers: $noteNumbers
                            )
                        }
                        else if variationTypes[key] == .variationSequencial {
                            NoteNumberSequenceView(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                noteNumbers: $noteNumbers,
                                notesSequenceType: $notesSequenceType
                            )
                        }
                    }
                }
                
                if showEditorPart == editorPart || showEditorPart == .position {
                    
                }
            }
        }
        
        if pleaseSave {
            Text("Please save en re-open the set to continue.")
                .foregroundColor(.red)
        }
        
        //New track
        HStack(){
            Group{
                Text("\(numberOfTracks) Tracks")
                    .font(.system(size: 20))
                    .padding(.top, 5)
                    .padding(.leading)
            }
            .frame(height: 45)
            
            Button("+"){
                if let newTrack = setInfoModel.addTrack(){
                    
                    //Add track
                    setInfoModel.setSettings.tracks[newTrack.trackId] = newTrack
                    
                    //Insert bindings tracks
                    trackLevels[newTrack.trackId] = newTrack.levels
                    noteNumbersLevels[newTrack.trackId] = newTrack.notesToLevel
                    midiClipsLevels[newTrack.trackId] = newTrack.loopsToLevel
                    noteNumbersPositions[newTrack.trackId] = newTrack.notesToGrid
                    midiClipPositions[newTrack.trackId] = newTrack.loopsToGrid
                    noteNumbers[newTrack.trackId] = newTrack.midiGroup
                    notesSequenceType[newTrack.trackId] = newTrack.notesSequenceType
                    let nclips = newTrack.midiGroup
                    noteNumberLetters[newTrack.trackId] = Array(0..<nclips.count).map{$0}
                    midiClips[newTrack.trackId] = newTrack.loopLength
                    let mclips = newTrack.loopLength
                    midiClipLetters[newTrack.trackId] = Array(0..<mclips.count).map{$0}
                    noteSources[newTrack.trackId] = newTrack.noteSource
                    startTypes[newTrack.trackId] = newTrack.startType
                    variationTypes[newTrack.trackId] = newTrack.variationType
                    availableVariationTypes[newTrack.trackId] = [.variationByLevel,.variationByPosition,.variationSequencial]
                    instrumentTypes[newTrack.trackId] = newTrack.instrumentType
                    //Insert bindings parts
                    let part = newTrack.parts.values.first!
                    areaOfInterest[part.partId] = part.areaOfInterest
                    minimalLevel[part.partId] = part.minimalLevel
                    
                    editorParts = setInfoModel.selectableEditorParts()
                    
                    numberOfTracks += 1
                    
                    pleaseSave = true
                }
            }
            .font(.system(size: 45))
            Spacer()
        }
        
        
    }
}
