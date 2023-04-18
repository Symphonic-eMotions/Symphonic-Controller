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
            
            HStack{
                
                Text("Note numbers")
                    .frame(width: columnWidth, alignment: .leading)
                
                ForEach(0..<noteNumbersLocal.count, id: \.self) { index in
                    
                    VStack{
                        
                        Image(systemName: isPlaying[index] ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 30)
                            .padding(.vertical, 5.0)
                            .padding(.horizontal, 5.0)
                            .background(Color.accentColor)
                            .cornerRadius(5.0)
                            .onTapGesture {
                                
                                setInfoModel.conductor.playNoteNumberSingleTrack(
                                    trackId: trackId,
                                    noteNumber: noteNumbersLocal[index],
                                    noteOn: isPlaying[index])
                                
                                isPlaying[index].toggle()
                            }
                        
                        TextField("Note number", text: Binding(
                            get: {String(self.noteNumbersLocal[index])},
                            set: {
                                if let value = Int($0) {
                                    self.noteNumbersLocal[index] = value
                                    currentTrack.midiGroup[index] = value
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
                        
                        let letter: String = AppUtils.midiNoteName(for: self.noteNumbersLocal[index])
                        Text("\(letter)").foregroundColor(.blue)
                    }
                }
                
                //Remove clip button
                Button("-") {
                    if (noteNumbersLocal.count) > 1 {
                        
                        
                    let oldLength: Int = noteNumbersLocal.count-1
                    //Mutate in file databse
                    currentTrack.midiGroup.removeLast()
                    //Binding structure
                    noteNumberLetters[trackId]!.removeLast()
                    //Interface
                    noteNumbersLocal.removeLast()
                    //Note number player
                    isPlaying.removeLast()
                        
                    let newLength: Int = noteNumbersLocal.count-1

                    print("TODO: Remove clip from notesToLevel")
//                    if currentTrack.loopsToLevel.contains(oldLength){
//                        currentTrack.loopsToLevel = currentTrack.loopsToLevel.map {
//                            $0 == oldLength ? newLength: $0
//                        }
//                    }
                    //Remove clip from notesToGrid
                    if currentTrack.notesToGrid.contains(oldLength){
                        currentTrack.notesToGrid = currentTrack.notesToGrid.map {
                            $0 == oldLength ? newLength: $0
                        }
                    }
                        
                    }
                }
                .disabled(noteNumbersLocal.count == 1)
                .font(.system(size: 35))
                
                //Add clip button
                Button("+") {
                    
                    let increment:Int = (currentTrack.midiGroup.last ?? 47) + 1
                    currentTrack.midiGroup.append(increment)
                    noteNumbersLocal.append(increment)
                    isPlaying.append(false)
                    noteNumberLetters[trackId]!.append(noteNumberLetters[trackId]!.count)
                }
                .font(.system(size: 35))
            }
            
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
