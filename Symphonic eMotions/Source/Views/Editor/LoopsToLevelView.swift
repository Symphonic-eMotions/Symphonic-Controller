//
//  LoopsToLevelView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 05/04/2023.
//

import SwiftUI

struct LoopLevelBox: View {
    
    var value: Int
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
            Text("\(value+1)")
                .foregroundColor(.primary)
        }
    }
}

struct LoopsToLevelView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String
    @State var loopLengthLocal: [Double] = []
    
//    @State private var levels: [Int]
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String ){
            self.setInfoModel = setInfoModel
            self.currentTrack = currentTrack
            self.trackId = trackId
            _loopLengthLocal = State(initialValue: currentTrack.loopLength)
    }
    
    
    
    var body: some View {
        VStack(alignment: .leading){
            
            HStack() {
                
                Text("MIDI File clip length in beats:")
                
                Button("-") {
                    if (loopLengthLocal.count) > 1 {
                        print("remove last from:")
                        loopLengthLocal.removeLast()
                        currentTrack.loopLength.removeLast()
                    }
                }
                .disabled(loopLengthLocal.count == 1)
                .font(.system(size: 30))
                
                ForEach(0..<loopLengthLocal.count, id: \.self) { index in
                    
                    ZStack {
                        
                        TextField("Loop", text: Binding(
                            get:{ String(loopLengthLocal[index]) },
                            set:{ if let value = Double($0) {
                                    //setInfoModel.setSettings.tracks[trackId]?.loopLength[index] = value
                                    currentTrack.loopLength[index] = value
                                    loopLengthLocal[index] = value
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50, height: 50)
                    }
                }
                
                Button("+") {
                    currentTrack.loopLength.append(16)
                    loopLengthLocal.append(16)
                }
                .font(.system(size: 30))
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
