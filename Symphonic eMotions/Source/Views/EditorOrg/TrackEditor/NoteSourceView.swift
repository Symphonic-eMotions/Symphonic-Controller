//
//  NoteSourceView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import SwiftUI

struct NoteSourceView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String

    let columnWidth: CGFloat = 150
    
    @Binding var noteSourceParent: [String: NoteSource]
    @State var localNoteSource: NoteSource
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        noteSourceParent: Binding<[String: NoteSource]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _noteSourceParent = noteSourceParent
        _localNoteSource = State(initialValue: currentTrack.noteSource)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack(){
                
                Text("Source of notes")
                    .frame(width: columnWidth, alignment: .leading)
                
                Picker("Select source of notes", selection: $localNoteSource) {
                    ForEach(NoteSource.allCases, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: localNoteSource) { noteSource in
                    withAnimation {
                        
                        //Store to file
                        currentTrack.noteSource = noteSource
                        //Tell parent
                        noteSourceParent[trackId] = noteSource
                        //Keep local state
                        localNoteSource = noteSource
                        //Reset clip
                        
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
