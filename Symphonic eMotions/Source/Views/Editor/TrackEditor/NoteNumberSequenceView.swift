//
//  NoteNumberSequenceView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/06/2023.
//

import SwiftUI

struct NoteNumberSequenceView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    //Higher level states with track id
    @Binding var noteNumbersPerTrack: [String:[Int]]
    
    //These are the stored note numbers in midiGroup
    @State var noteNumbersLocal: [Int]
    
    @State var noteNumberSequenceLocal: NotesSequenceType
    
    @State var updateView: Int = 0
        
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId: String,
        noteNumbersPerTrack: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _noteNumbersPerTrack = noteNumbersPerTrack
        _noteNumbersLocal = State(initialValue: currentTrack.midiGroup)
        
        _noteNumberSequenceLocal = State(initialValue: currentTrack.notesSequenceType)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
//            NoteNumberView(
//                setInfoModel: setInfoModel,
//                currentTrack: currentTrack,
//                trackId: trackId,
//                noteNumbersLocal: $noteNumbersLocal,
//                noteNumbersPerTrack: $noteNumbersPerTrack,
//                updateView: $updateView
//            )
            
            HStack(){
                
                Text("Note sequence:")
                    .frame(width: columnWidth, alignment: .leading)
                
                Picker("Select sequence type", selection: $noteNumberSequenceLocal) {
                    ForEach(NotesSequenceType.allCases, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: noteNumberSequenceLocal) { sequenceType in
                    withAnimation {
                        //Store to file
                        currentTrack.notesSequenceType = sequenceType
                        //Keep local state
                        noteNumberSequenceLocal = sequenceType
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
