//
//  EditTracks.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/04/2023.
//

import SwiftUI

struct Item: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let details: String
}

struct EditTracks: View {

    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var showEditorPart: String
    @State var trackTypeLocal: [String: TrackType]
    @State var noteSourceLocal: [String: NoteSource]
    //Linear representation of the midi clips.
    //Modified by MidiClipsInFile
    @State var midiClipLetters: [String: [Int]]
    //Representation note numbers NoteNumberToGrid
    @State var noteNumberLetter: [String: [Int]]
    
    init(
        setInfoModel: SetInfoModel,
        showEditorPart: Binding<String>
    ) {
        self.setInfoModel = setInfoModel
        _showEditorPart = showEditorPart
        
        var tmpTrackType = [String: TrackType]()
        var tmpNoteSource = [String: NoteSource]()
        //Make for all tracks a shared trackType and noteSource dictionary
        for track in setInfoModel.setSettings.tracks {
            tmpTrackType[track.value.trackId] = track.value.trackType
            tmpNoteSource[track.value.trackId] = track.value.noteSource
        }
        _trackTypeLocal = State(initialValue: tmpTrackType)
        _noteSourceLocal = State(initialValue: tmpNoteSource)
        
        var tmpClipLetters = [String: [Int]]()
        for track in setInfoModel.setSettings.tracks {
            let clips = track.value.loopLength
            tmpClipLetters[track.value.trackId] = Array(0..<clips.count).map{$0}
            
        }
        _midiClipLetters = State(initialValue: tmpClipLetters)
        
        var tmpNoteNumberLetters = [String: [Int]]()
        for track in setInfoModel.setSettings.tracks {
            let clips = track.value.midiGroup
            tmpNoteNumberLetters[track.value.trackId] = Array(0..<clips.count)
            .map{track.value.midiGroup[$0]}
        }
        _noteNumberLetter = State(initialValue: tmpNoteNumberLetters)
    }
    
    var body: some View {

        VStack(alignment: .leading) {

            ForEach(setInfoModel.setSettings.tracks.keys, id: \.self) { key in
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

                    Text("Track \(setInfoModel.setSettings.tracks[key]!.trackName)")
                        .font(.system(size: 20))
                        .padding()
                    
                    Spacer()
                    
                    VStack(alignment: .trailing){
                        Text(setInfoModel.setSettings.tracks[key]!.startType.description)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(setInfoModel.setSettings.tracks[key]!.noteSource.description)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(setInfoModel.setSettings.tracks[key]!.trackType.description)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .onTapGesture {
                    withAnimation {
                        if showEditorPart != key {
                            showEditorPart = key
                            trackTypeLocal[key] = setInfoModel.setSettings.tracks[key]!.trackType
                        } else {
                            showEditorPart = "none"
                        }
                    }
                }
                //If navigation header is tapped
                if showEditorPart == key || showEditorPart == "levels" {
                    
                    InLevelView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key
                    )
                    
                }
                if showEditorPart == key {
                    
                    //Source of notes
                    NoteSourceView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        noteSourceParent: $noteSourceLocal
                    )
                    
                    //Start type
                    StartTypeView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key
                    )
                    
                    //MIDI clip variations
                    TrackTypeView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        trackTypeParent: $trackTypeLocal
                    )
                    
                    if trackTypeLocal[key] == .variationByLevel {
                        
                        if noteSourceLocal[key] == .midiFile {
                            LoopsToLevelView(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                clipLetters: $midiClipLetters
                            )
                        }
                        else if noteSourceLocal[key] == .noteNumbers {
                            NoteNumberToLevelView(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                noteNumberLetters: $noteNumberLetter
                            )
                        }
                    }
                    else if trackTypeLocal[key] == .variationByPosition {
                        
                        if noteSourceLocal[key] == .midiFile {
                            LoopsToGridView(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                clipLetters: $midiClipLetters
                            )
                        }
                        else if noteSourceLocal[key] == .noteNumbers {
                            NoteNumberToGrid(
                                setInfoModel: setInfoModel,
                                currentTrack: setInfoModel.setSettings.tracks[key]!,
                                trackId: key,
                                noteNumberLetters: $noteNumberLetter
                            )
                        }
                    }
                }
                Divider()
            }
        }
    }
}
