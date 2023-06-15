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
    
    var body: some View {
        
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
                        //Explude TextField from parent onTapGesture
                        .onTapGesture{}
                    }
                    else{
                        Text("Track \(track.trackName)")
                            .font(.system(size: 20))
                            .padding()
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
                        midiClipspositions: $midiClipPositions
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
