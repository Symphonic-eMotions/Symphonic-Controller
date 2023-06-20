//
//  NoteNumberLevelView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2023.
//

import SwiftUI

struct NoteNumberLevelView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    //Binding
    @Binding var trackLevels: [String: [Int]]
    @Binding var noteNumbersLevels: [String: [Int]]
    @Binding var noteNumbers: [String: [Int]]
    
    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId: String,
        trackLevels: Binding<[String:[Int]]>,
        noteNumbersLevels: Binding<[String:[Int]]>,
        noteNumbers: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _trackLevels = trackLevels
        _noteNumbersLevels = noteNumbersLevels
        _noteNumbers = noteNumbers
    }
    
    let columnWidth: CGFloat = 150
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack(){
                
                Text("Place note in level: ")
                .frame(width: columnWidth, alignment: .leading)

                ForEach(0..<trackLevels[trackId]!.count, id: \.self) { level in

                    VStack{
                        
                        let levelNumber = level+1
                        Text("\(levelNumber)")
                            .foregroundColor(.blue)
                        
                        ZStack {

                            let levelNoteNumber = noteNumbersLevels[trackId]![level]
                            let noteName: String = AppUtils.midiNoteName(for: levelNoteNumber)
                            
                            Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            
                            Text("\(noteName)")
                            .foregroundColor(.white)
                        }
                        .onTapGesture {
                            
                            //Find index in noteNumbersLocal
                            let currentValue = noteNumbersLevels[trackId]![level]
                            if let noteIndex = noteNumbers[trackId]!.firstIndex(where: {$0 == currentValue}){
                                //Increment index
                                var incrementNoteIndex = noteIndex+1
                                //If index is higher then count then index = 0
                                if incrementNoteIndex >= noteNumbers[trackId]!.count {
                                    incrementNoteIndex = 0
                                }
                                
                                noteNumbersLevels[trackId]![level] = noteNumbers[trackId]![incrementNoteIndex]
                                currentTrack.notesToLevel[level] = noteNumbers[trackId]![incrementNoteIndex]
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
