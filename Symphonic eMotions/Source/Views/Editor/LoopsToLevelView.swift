//
//  LoopsToLevelView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 05/04/2023.
//

import SwiftUI

struct MidiClipName: View {
    
    var value: String
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
            Text("\(value)")
                .foregroundColor(.primary)
        }
    }
}

struct ClipToLevel: View {
    
    var value: String
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .frame(width: 50, height: 50)
                .foregroundColor(.clear)
                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
            Text("\(value)")
                .foregroundColor(.blue)
                .onTapGesture {
                    print("Increment clip name with modulo count clip names")
                }
        }
    }
}

struct LoopsToLevelView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String
    @State var loopLengthLocal: [Double]
    @State var clipLength: Int
    @State private var levels: [Int]
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String ){
            self.setInfoModel = setInfoModel
            self.currentTrack = currentTrack
            self.trackId = trackId
            _loopLengthLocal = State(initialValue: currentTrack.loopLength)
            _clipLength = State(initialValue: Int(currentTrack.loopLength.first ?? 16))
            _levels = State(initialValue: setInfoModel.setSettings.levels)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            
            Divider()
            
            HStack() {
                
                Text("MIDI clip names")
                .frame(width: columnWidth, alignment: .leading)
                
                ForEach(0..<loopLengthLocal.count, id: \.self) { index in
                    
                    VStack {
                        if let letter: String = AppUtils.letterForNumber(index) {
                            ZStack{
                                MidiClipName(value: letter)
                            }
                        }
                    }
                }
                
                Button("-") {
                    if (loopLengthLocal.count) > 1 {
                        print("remove last from:")
                        loopLengthLocal.removeLast()
                        currentTrack.loopLength.removeLast()
                    }
                }
                .disabled(loopLengthLocal.count == 1)
                .font(.system(size: 30))
                
                Button("+") {
                    currentTrack.loopLength.append(16)
                    loopLengthLocal.append(16)
                }
                .font(.system(size: 30))
            }
            
            Divider()
            
            HStack(){
                
                Text("MIDI Clip lengths")
                    .frame(width: columnWidth, alignment: .leading)
                
                TextField("Cliplength", text: Binding(
                    get:{ String(clipLength) },
                    set:{ if let value = Double($0) {
                        clipLength = Int(value)
                        currentTrack.loopLength = Array(repeating: value, count: currentTrack.loopLength.count)
                    }}
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 40, height: 25)
                
                Text("beats")
                    .frame(width: columnWidth, alignment: .leading)
            }
            
            Divider()
            
            HStack(){
                Text("Place clip in level: ")
                    .frame(width: columnWidth, alignment: .leading)
                
                ForEach(0..<levels.count, id: \.self) { index in
                    
                    VStack{
                        
                        if let letter: String = AppUtils.letterForNumber(currentTrack.loopsToLevel[index]) {
                            ClipToLevel(value: letter)
                        }
                        
                        
                    }
                }
            }
        }
        .padding(.leading)
        .onAppear {
            // Set initial value of syncedValue to value from observed object
            loopLengthLocal = setInfoModel.setSettings.tracks[trackId]!.loopLength
        }
        .onChange(of: setInfoModel.setSettings.tracks[trackId]!.loopLength) { newValue in
            // Update syncedValue when value in observed object changes
            loopLengthLocal = newValue
        }
//        .onChange(of: loopLengthLocal) { newValue in
//            // Update value in observed object when syncedValue changes
//            loopLengthLocal.value = newValue
//        }
    }
    
}
