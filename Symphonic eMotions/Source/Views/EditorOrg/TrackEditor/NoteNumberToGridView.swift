//
//  NoteNumberToGrid.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 13/04/2023.
//

import SwiftUI

struct NoteNumberToGridView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    
    //Higher level states with track id
    @Binding var noteNumbersPerTrack: [String:[Int]]
    
    //This is a 1 track View
    @State var trackId: String
    
    //These are the stored note numbers in midiGroup
    @State var noteNumbersLocal: [Int]
    //Keep track of note numbers for the View refresh
    @State var notesToGridLocal: [Int]
    
    @State private var updateView: Int = 0
    
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
        //We keep track of all note numbers on track level
        _noteNumbersPerTrack = noteNumbersPerTrack
        //These are the available note numbers for te view
        _noteNumbersLocal = State(initialValue: currentTrack.midiGroup)
        //These are placed note numbers in the grid
        _notesToGridLocal = State(initialValue: currentTrack.notesToGrid)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            if currentTrack.noteSource == .noteNumbers && currentTrack.startType == .loopedTransport {
                
                Text("Note number start with transport has no positions")
                    
            }
            else{
                
//                NoteNumberView(
//                    setInfoModel: setInfoModel,
//                    currentTrack: currentTrack,
//                    trackId: trackId,
//                    noteNumbersLocal: $noteNumbersLocal,
//                    noteNumbersPerTrack: $noteNumbersPerTrack,
//                    updateView: $updateView
//                )
                
                HStack(){
                    
                    Text("Place note numbers in grid:")
                        .frame(width: columnWidth, alignment: .leading)
                    
                    let gridRows: Int = setInfoModel.setSettings.gridRows
                    let gridColumns: Int = setInfoModel.setSettings.gridColumns
                    
                    //Note number grid
                    VStack(spacing: 0) {
                        ForEach(0..<gridRows, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<gridColumns, id: \.self) { column in
                                    
                                    //Current cell index
                                    let cellIndex =  row * gridColumns + column
                                    
                                    //The cell buttons
                                    ZStack {
                                        
                                        Rectangle()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.clear)
                                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                        
                                        let gridNote = notesToGridLocal[cellIndex]
                                        let noteName: String = AppUtils.midiNoteName(for: gridNote)
                                        
                                        Text("\(noteName)")
                                            .foregroundColor(.blue)
                                    }
                                    .onTapGesture {
                                        //Loop through available notenumbers
                                        let currentValue = notesToGridLocal[cellIndex]
                                        if let noteIndex = noteNumbersLocal.firstIndex(where: {$0 == currentValue}){
                                            //Increment index
                                            var incrementNoteIndex = noteIndex + 1
                                            //If index is higher then count then index = 0
                                            if incrementNoteIndex >= noteNumbersLocal.count {
                                                incrementNoteIndex = 0
                                            }
                                            
                                            currentTrack.notesToGrid[cellIndex] = noteNumbersLocal[incrementNoteIndex]
                                            notesToGridLocal[cellIndex] = noteNumbersLocal[incrementNoteIndex]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading)
        .onChange(of: updateView) { _ in
            notesToGridLocal = currentTrack.notesToGrid
        }
    }
}
