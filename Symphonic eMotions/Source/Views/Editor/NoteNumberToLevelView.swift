//
//  NoteNumberToLevelView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2023.
//

import SwiftUI

struct NoteNumberToLevelView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
     
    @State private var levels: [Int]
    
    //These are the stored note numbers in midiGroup
    @State var noteNumbersLocal: [Int]
    //Keep track of note numbers for the View refresh
    //Higher level states with track id
    @Binding var noteNumberLetters: [String:[Int]]
    @State var notesToLevelLocal: [Int]
    
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
        _levels = State(initialValue: setInfoModel.setSettings.levels)
        _noteNumberLetters = noteNumberLetters
        _noteNumbersLocal = State(initialValue: currentTrack.midiGroup)
        _notesToLevelLocal = State(initialValue: currentTrack.notesToLevel)
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
                
                Text("Place note number in level: ")
                .frame(width: columnWidth, alignment: .leading)

                ForEach(0..<levels.count, id: \.self) { index in

                    VStack{

                        ZStack {

                            let levelNoteNumber = notesToLevelLocal[index]
                            let noteName: String = AppUtils.midiNoteName(for: levelNoteNumber)
                            
                            Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            
                            Text("\(noteName)")
                            .foregroundColor(.blue)
                        }
                        .onTapGesture {
                            
                            //Find index in noteNumbersLocal
                            let currentValue = notesToLevelLocal[index]
                            if let noteIndex = noteNumbersLocal.firstIndex(where: {$0 == currentValue}){
                                //Increment index
                                var incrementNoteIndex = noteIndex+1
                                //If index is higher then count then index = 0
                                if incrementNoteIndex >= noteNumbersLocal.count {
                                    incrementNoteIndex = 0
                                }
                                
                                notesToLevelLocal[index] = noteNumbersLocal[incrementNoteIndex]
                                currentTrack.notesToLevel[index] = noteNumbersLocal[incrementNoteIndex]
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading)
//        .onAppear {
//            // Set initial value of syncedValue to value from observed object
//            notesToLevelLocal = setInfoModel.setSettings.tracks[trackId]!.notesToLevel
//        }
//        .onChange(of: setInfoModel.setSettings.levels) { newValue in
//            // Update syncedValue when value in observed object changes
//            notesToLevelLocal = newValue
//        }
    }
}
