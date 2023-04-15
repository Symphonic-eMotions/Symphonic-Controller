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
    @State var midiGroupLocal: [Int]
    @Binding var clipLetters: [String:[Int]]
    @State var isPlaying: [Bool]
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId: String,
        clipLetters: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _clipLetters = clipLetters
        _midiGroupLocal = State(initialValue: currentTrack.midiGroup)
        _isPlaying = State(initialValue: Array(repeating: false, count: currentTrack.midiGroup.count))
    }
    
    var body: some View {
        
        HStack{
            
            Text("Note numbers")
                .frame(width: columnWidth, alignment: .leading)
            
            ForEach(0..<midiGroupLocal.count, id: \.self) { index in
                
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
                            noteNumber: midiGroupLocal[index],
                            noteOn: isPlaying[index])
                        
                        isPlaying[index].toggle()
                    }
                    
                    TextField("Note number", text: Binding(
                        get: {String(self.midiGroupLocal[index])},
                        set: {
                            if let value = Int($0) {
                                self.midiGroupLocal[index] = value
                                currentTrack.midiGroup[index] = value
                            }
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                }
            }
            
            //Remove clip button
            Button("-") {
                if (midiGroupLocal.count) > 1 {
                    
//                    let oldLength: Int = midiGroupLocal.count-1
                    //Mutate in file databse
                    currentTrack.midiGroup.removeLast()
                    //Binding structure
//                    clipLetters[trackId]!.removeLast()
                    //Interface
                    midiGroupLocal.removeLast()
                    //Midiclip player
                    isPlaying.removeLast()
                    
//                    let newLength: Int = midiGroupLocal.count-1
                    
                    //Remove clip from loopsToLevel
//                    if currentTrack.loopsToLevel.contains(oldLength){
//                        currentTrack.loopsToLevel = currentTrack.loopsToLevel.map {
//                            $0 == oldLength ? newLength: $0
//                        }
//                    }
//                    //Remove clip from loopsToGrid
//                    if currentTrack.loopsToGrid.contains(oldLength){
//                        currentTrack.loopsToGrid = currentTrack.loopsToGrid.map {
//                            $0 == oldLength ? newLength: $0
//                        }
//                    }
                }
            }
            .disabled(midiGroupLocal.count == 1)
            .font(.system(size: 35))
            
            //Add clip button
            Button("+") {
                
                let increment:Int = (currentTrack.midiGroup.last ?? 47) + 1
                currentTrack.midiGroup.append(increment)
                midiGroupLocal.append(increment)
                isPlaying.append(false)
//                clipLetters[trackId]!.append(clipLetters[trackId]!.count)
            }
            .font(.system(size: 35))
        }
        .padding(.leading)
    }
}
