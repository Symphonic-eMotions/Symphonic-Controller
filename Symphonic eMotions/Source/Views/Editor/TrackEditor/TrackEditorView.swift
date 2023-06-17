//
//  TrackEditorView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 15/06/2023.
//

import SwiftUI

struct TrackEditorView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
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
    @Binding var noteNumberLetters: [String: [Int]]
    
    //Midi cips per track
    @Binding var midiClips: [String: [Double]]
    @Binding var midiClipLetters: [String: [Int]]
    
    //Types per tracks
    @Binding var noteSources: [String: NoteSource]
    @Binding var startTypes: [String: StartType]
    @Binding var variationTypes: [String: VariationType]
    @Binding var instrumentTypes: [String: InstrumentsSet.Track.InstrumentType]
    
    //Part variables
    @Binding var areaOfInterest: [String: [Int]]
    @Binding var minimalLevel: [String: Double]
    
    //State
    @State private var showRemoveConfirmation: Bool = false
    
    var body: some View {
        
        HStack(){
            Text("\(numberOfTracks) Tracks")
                .font(.system(size: 20))
                .padding()
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
                    let nclips = newTrack.midiGroup
                    noteNumberLetters[newTrack.trackId] = Array(0..<nclips.count).map{$0}
                    midiClips[newTrack.trackId] = newTrack.loopLength
                    let mclips = newTrack.loopLength
                    midiClipLetters[newTrack.trackId] = Array(0..<mclips.count).map{$0}
                    noteSources[newTrack.trackId] = newTrack.noteSource
                    startTypes[newTrack.trackId] = newTrack.startType
                    variationTypes[newTrack.trackId] = newTrack.variationType
                    instrumentTypes[newTrack.trackId] = newTrack.instrumentType
                    //Insert bindings parts
                    let part = newTrack.parts.values.first!
                    areaOfInterest[part.partId] = part.areaOfInterest
                    minimalLevel[part.partId] = part.minimalLevel
                    
                    numberOfTracks += 1
                }
            }
            .font(.system(size: 45))
            Spacer()
        }
        
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
                        Text("Track \(track.trackName)")
                            .font(.system(size: 20))
                            .padding()
                    }
                    
                    Spacer()
                    
                    //Remove track
                    Button("-"){
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
                                //First remove part bindings with track info
                                let parts = setInfoModel.setSettings.tracks[key]!.parts
                                for part in parts {
                                    areaOfInterest.removeValue(forKey: part.value.partId)
                                    minimalLevel.removeValue(forKey: part.value.partId)
                                }
                                //Mutate struct for writing to file
                                setInfoModel.setSettings.tracks.removeValue(forKey: key)
                                //Mutate bindings
                                trackLevels.removeValue(forKey: key)
                                noteNumbersLevels.removeValue(forKey: key)
                                midiClipsLevels.removeValue(forKey: key)
                                noteNumbersPositions.removeValue(forKey: key)
                                midiClipPositions.removeValue(forKey: key)
                                noteNumbers.removeValue(forKey: key)
                                noteNumberLetters.removeValue(forKey: key)
                                midiClips.removeValue(forKey: key)
                                midiClipLetters.removeValue(forKey: key)
                                noteSources.removeValue(forKey: key)
                                startTypes.removeValue(forKey: key)
                                variationTypes.removeValue(forKey: key)
                                instrumentTypes.removeValue(forKey: key)
                                
                                numberOfTracks -= 1
                            },
                            secondaryButton: .cancel()
                        )
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
                if showEditorPart == editorPart || showEditorPart == .source {
                    
                    NoteSourceView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        showEditorPart: $showEditorPart,
                        noteSources: $noteSources,
                        midiClips: $midiClips,
                        midiClipLetters: $midiClipLetters,
                        midiClipsLevels: $midiClipsLevels,
                        midiClipspositions: $midiClipPositions,
                        noteNumbers: $noteNumbers,
                        noteNumberLetters: $noteNumberLetters
                    )
                }
                if showEditorPart == editorPart || showEditorPart == .sound {
                    
                    SoundSourceView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        showEditorPart: $showEditorPart,
                        soundSources: $instrumentTypes)
                }
            }
        }
    }
}
