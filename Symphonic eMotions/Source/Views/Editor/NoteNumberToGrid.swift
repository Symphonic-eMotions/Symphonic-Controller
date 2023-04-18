//
//  NoteNumberToGrid.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 13/04/2023.
//

import SwiftUI

struct NoteNumberToGrid: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    //These are the stored note numbers in midiGroup
    @State var noteNumbersLocal: [Int]
    //Keep track of note numbers for the View refresh
    @State var notesToGridLocal: [Int]
    //Higher level states with track id
    @Binding var noteNumberLetters: [String:[Int]]
    @State var isPlaying: [Bool]
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId: String,
        noteNumberLetters: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _noteNumberLetters = noteNumberLetters
        _noteNumbersLocal = State(initialValue: currentTrack.midiGroup)
        _notesToGridLocal = State(initialValue: currentTrack.notesToGrid)
        _isPlaying = State(initialValue: Array(repeating: false, count: currentTrack.midiGroup.count))
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            NoteNumberView(
                setInfoModel: setInfoModel,
                currentTrack: currentTrack,
                trackId: trackId,
                noteNumbersLocal: $noteNumbersLocal,
                noteNumberLetters: $noteNumberLetters
            )
            
            HStack(){
                
                Text("Place note numbers in grid: ")
                .frame(width: columnWidth, alignment: .leading)
        
                let gridRows: Int = setInfoModel.setSettings.gridRows
                let gridColumns: Int = setInfoModel.setSettings.gridColumns
                                
                VStack(spacing: 0) {
                    ForEach(0..<gridRows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<gridColumns, id: \.self) { column in
                                
                                let cellIndex =  row * gridColumns + column
                                
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
                                    
                                    var increment = notesToGridLocal[cellIndex] + 1
                                    
                                    if !noteNumbersLocal.contains(increment) {
                                        increment = notesToGridLocal.min() ?? 48
                                    }
                                        
                                    currentTrack.notesToGrid[cellIndex] = increment
                                    notesToGridLocal[cellIndex] = increment
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
