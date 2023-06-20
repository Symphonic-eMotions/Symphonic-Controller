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
    //This is a 1 track view
    @State var trackId: String
    
    //Bindings
    @Binding var noteNumbers: [String: [Int]]
    @Binding var notesSequenceType: [String: NotesSequenceType]
    
    //States
    @State private var selectedSequenceType: NotesSequenceType

    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId: String,
        noteNumbers: Binding<[String:[Int]]>,
        notesSequenceType: Binding<[String:NotesSequenceType]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _noteNumbers = noteNumbers
        _notesSequenceType = notesSequenceType
        
        _selectedSequenceType = State(initialValue: notesSequenceType.wrappedValue[trackId] ?? .nextForward)
    }

    let columnWidth: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading){
            
            Divider()

            HStack(){
                Text("Note sequence:")
                    .frame(width: columnWidth, alignment: .leading)

                Picker("Select sequence type", selection: $selectedSequenceType) {
                    ForEach(NotesSequenceType.allCases, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(.inline)
                .frame(width:350, height: 100)
                .onChange(of: selectedSequenceType) { sequenceType in
                    withAnimation {
                        //Store to file
                        currentTrack.notesSequenceType = sequenceType
                        //Keep local state
                        notesSequenceType[trackId] = sequenceType
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
