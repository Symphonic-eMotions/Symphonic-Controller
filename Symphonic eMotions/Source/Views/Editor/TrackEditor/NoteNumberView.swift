//
//  NoteNumberView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2023.
//

import SwiftUI

struct NoteNumberView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    @Binding var noteNumbersLocal: [Int]
    @Binding var noteNumbersPerTrack: [String:[Int]]
    @State var isPlaying: [Bool]
    @Binding var updateView: Int
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        noteNumbersLocal: Binding<[Int]>,
        noteNumbersPerTrack: Binding<[String:[Int]]>,
        updateView: Binding<Int>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _noteNumbersLocal = noteNumbersLocal
        _noteNumbersPerTrack = noteNumbersPerTrack
        _isPlaying = State(initialValue: Array(repeating: false, count: noteNumbersLocal.count))
        _updateView = updateView
    }
    
    var body: some View {
        
        HStack{
            
            VStack{
                
                Text("Note numbers")
                    .frame(width: columnWidth, alignment: .leading)
                
                HStack{
                    
                    //Remove note button
                    Button("-") {
                        if (noteNumbersLocal.count) > 1 {
                            
                            let oldLength: Int = noteNumbersLocal.count-1
                            let oldNote: Int = noteNumbersLocal[oldLength]
                            //Mutate in file databse
                            currentTrack.midiGroup.removeLast()
                            //Binding structure
                            noteNumbersPerTrack[trackId]!.removeLast()
                            //Interface
                            noteNumbersLocal.removeLast()
                            //Note number player
                            isPlaying.removeLast()
                            
                            let newLength: Int = noteNumbersLocal.count-1
                            let newNote: Int = noteNumbersLocal[newLength]
                            
                            //Replace note in level
                            for (i, n) in currentTrack.notesToLevel.enumerated() {
                                if n == oldNote {
                                    currentTrack.notesToLevel[i] = newNote
                                }
                            }
                            //Replace note in grid
                            for (i, n) in currentTrack.notesToGrid.enumerated() {
                                if n == oldNote {
                                    currentTrack.notesToGrid[i] = newNote
                                }
                            }
                            updateView += 1
                        }
                    }
                    .disabled(noteNumbersLocal.count == 1)
                    .font(.system(size: 35))
                    
                    //Add note button
                    Button("+") {
                        
                        let increment:Int = (currentTrack.midiGroup.last ?? 47) + 1
                        currentTrack.midiGroup.append(increment)
                        noteNumbersLocal.append(increment)
                        isPlaying.append(false)
                        noteNumbersPerTrack[trackId]!.append(increment)
                        updateView += 1
                    }
                    .font(.system(size: 35))
                }
            }
            
            //Note number ingterface
            ScrollView(.horizontal) {
                
                HStack{
                    
                    ForEach(0..<noteNumbersLocal.count, id: \.self) { index in
                        
                        VStack{
                            
                            //Play stop current note
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
                            
                            HStack{
                                //Lower current note
                                Button("-") {
                                    //Stop if playing
                                    if isPlaying[index] {
                                        setInfoModel.conductor.playNoteNumberSingleTrack(
                                            trackId: trackId,
                                            noteNumber: noteNumbersLocal[index],
                                            noteOn: isPlaying[index])
                                        isPlaying[index] = false;
                                    }
                                    //Decrease note number up to number which not exists yet
                                    if noteNumbersLocal[index] > 0 {
                                        
                                        let oldNote = noteNumbersLocal[index]
                                        
                                        noteNumbersLocal[index] -= 1
                                        while(currentTrack.midiGroup.contains(noteNumbersLocal[index])){
                                            noteNumbersLocal[index] -= 1
                                        }
                                        //Store new value
                                        currentTrack.midiGroup[index] = noteNumbersLocal[index]
                                        
                                        //Replace note in level
                                        for (i, n) in currentTrack.notesToLevel.enumerated() {
                                            if n == oldNote {
                                                currentTrack.notesToLevel[i] = noteNumbersLocal[index]
                                            }
                                        }
                                        //Replace note in grid
                                        for (i, n) in currentTrack.notesToGrid.enumerated() {
                                            if n == oldNote {
                                                currentTrack.notesToGrid[i] = noteNumbersLocal[index]
                                            }
                                        }
                                        //Tell parent View
                                        for (i, n) in noteNumbersPerTrack[trackId]!.enumerated() {
                                            if n == oldNote {
                                                noteNumbersPerTrack[trackId]![i] = noteNumbersLocal[index]
                                            }
                                        }
                                        updateView += 1
                                    }
                                }
                                .font(.system(size: 35))
                                .disabled(noteNumbersLocal[index] == 1)
                                .padding(.leading)
                                
                                Text(String(self.noteNumbersLocal[index]))
                                .frame(width: 50)
                                
                                Button("+") {
                                    //Stop if playing
                                    if isPlaying[index] {
                                        setInfoModel.conductor.playNoteNumberSingleTrack(
                                            trackId: trackId,
                                            noteNumber: noteNumbersLocal[index],
                                            noteOn: isPlaying[index])
                                        isPlaying[index] = false;
                                    }
                                    //Increae note number up to number which not exists yet
                                    if noteNumbersLocal[index] < 127 {
                                        
                                        let oldNote = noteNumbersLocal[index]
                                        
                                        //No double note numbers alowed
                                        noteNumbersLocal[index] += 1
                                        while(currentTrack.midiGroup.contains(noteNumbersLocal[index])){
                                            noteNumbersLocal[index] += 1
                                        }
                                        //Store new value
                                        currentTrack.midiGroup[index] = noteNumbersLocal[index]
                                        
                                        //Replace note in level
                                        for (i, n) in currentTrack.notesToLevel.enumerated() {
                                            if n == oldNote {
                                                currentTrack.notesToLevel[i] = noteNumbersLocal[index]
                                            }
                                        }
                                        //Replace note in grid
                                        for (i, n) in currentTrack.notesToGrid.enumerated() {
                                            if n == oldNote {
                                                currentTrack.notesToGrid[i] = noteNumbersLocal[index]
                                            }
                                        }
                                        //Tell parent View
                                        for (i, n) in noteNumbersPerTrack[trackId]!.enumerated() {
                                            if n == oldNote {
                                                noteNumbersPerTrack[trackId]![i] = noteNumbersLocal[index]
                                            }
                                        }
                                        updateView += 1
                                    }
                                }
                                .font(.system(size: 35))
                                .disabled(noteNumbersLocal[index] == 127)
                                .padding(.trailing)
                            }
                            
                            let letter: String = AppUtils.midiNoteName(for: self.noteNumbersLocal[index])
                            Text("\(letter)").foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}
