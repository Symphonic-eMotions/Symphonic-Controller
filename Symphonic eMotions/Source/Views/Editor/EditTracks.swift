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
    //Linear representation of the midi clips.
    //Modified by MidiClipsInFile
    //Used by
    @State var clipLetters: [String: [Int]]
    
    init(
        setInfoModel: SetInfoModel,
        showEditorPart: Binding<String>
    ) {
        self.setInfoModel = setInfoModel
        _showEditorPart = showEditorPart
        
        var tmpTrackType = [String: TrackType]()
        for track in setInfoModel.setSettings.tracks {
            tmpTrackType[track.value.trackId] = track.value.trackType
        }
        _trackTypeLocal = State(initialValue: tmpTrackType)
        
        var tmpClipLetters = [String: [Int]]()
        for track in setInfoModel.setSettings.tracks {
            let clips = track.value.loopLength
            tmpClipLetters[track.value.trackId] = Array(0..<clips.count).map{$0}
        }
        _clipLetters = State(initialValue: tmpClipLetters)
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
                }
                .onTapGesture {
                    withAnimation {
                        if showEditorPart != key {
                            showEditorPart = key
                            trackTypeLocal[key] = setInfoModel.setSettings.tracks[key]!.trackType
                        }
                    }
                }
                //If navigation header is tapped
                if showEditorPart == key {

                    InLevelView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key
                    )
                    
                    //MIDI clip control
                    TrackTypeView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key,
                        trackTypeParent: $trackTypeLocal
                    )
                    

//                    Text("Start Type [transport, triggerSequencer, triggerTimeLess]")
//                        .padding()
//                        .foregroundColor(.gray)
                    
                    if trackTypeLocal[key] == .midiClipLevel {
                        LoopsToLevelView(
                            setInfoModel: setInfoModel,
                            currentTrack: setInfoModel.setSettings.tracks[key]!,
                            trackId: key,
                            clipLetters: $clipLetters
                        )
                    }
                    else if trackTypeLocal[key] == .midiClipPosition {
                        LoopsToGridView(
                            setInfoModel: setInfoModel,
                            currentTrack: setInfoModel.setSettings.tracks[key]!,
                            trackId: key,
                            clipLetters: $clipLetters
                        )
                    }
                    else if trackTypeLocal[key] == .midiGroupTrigger {
                        NoteNumberToGrid(
                            setInfoModel: setInfoModel,
                            currentTrack: setInfoModel.setSettings.tracks[key]!,
                            trackId: key,
                            clipLetters: $clipLetters
                        )
                    }
                }
            }
        }
    }
}
