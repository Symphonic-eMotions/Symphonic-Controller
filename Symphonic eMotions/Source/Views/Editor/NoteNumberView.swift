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
    @Binding var noteNumberLetters: [String:[Int]]
    @State var isPlaying: [Bool]
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        noteNumbersLocal: Binding<[Int]>,
        noteNumberLetters: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _noteNumbersLocal = noteNumbersLocal
        _noteNumberLetters = noteNumberLetters
        _isPlaying = State(initialValue: Array(repeating: false, count: noteNumbersLocal.count))
    }
    
    var body: some View {
        
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
                            //Turn of any running notes
                            if isPlaying[index] {
                                setInfoModel.conductor.playNoteNumberSingleTrack(
                                    trackId: trackId,
                                    noteNumber: noteNumbersLocal[index],
                                    noteOn: isPlaying[index])
                                
                                isPlaying[index].toggle()
                            }
                            //Stop playing
                            if let value = Int($0), value >= 0, value <= 127 {
                                self.noteNumbersLocal[index] = value
                                currentTrack.midiGroup[index] = value
                            }
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    
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
        
    }
}
