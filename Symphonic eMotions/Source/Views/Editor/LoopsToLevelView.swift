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

struct LoopsToLevelView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String
    @State var loopLengthLocal: [Double]
    @State var clipLength: Int
    @State private var levels: [Int]
    @State private var clipLetters: [Int]
    
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
            _clipLetters = State(initialValue: currentTrack.loopsToLevel)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            
            Divider()
            //MIDI clips in file
            HStack() {
                
                Text("MIDI clips in file")
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
                        
                        let oldLength: Int = currentTrack.loopLength.count-1
                        //Mutate
                        currentTrack.loopLength.removeLast()
                        loopLengthLocal.removeLast()
                        let newLength: Int = currentTrack.loopLength.count-1
                        
                        if currentTrack.loopsToLevel.contains(oldLength){
                            currentTrack.loopsToLevel = currentTrack.loopsToLevel.map {
                                $0 == oldLength ? newLength: $0
                            }
                            clipLetters = currentTrack.loopsToLevel
                        }
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
            //MIDI clip lengths
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
            //Place clips in level
            HStack(){
                
                Text("Place clip in level: ")
                .frame(width: columnWidth, alignment: .leading)
                
                ForEach(0..<levels.count, id: \.self) { index in
                    
                    VStack{
                        
                        ZStack {
                            
                            Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        
                            let levelClip = clipLetters[index]
                            let clipLetter: String = AppUtils.letterForNumber(levelClip) ?? "-"
                            
                            Text("\(clipLetter)")
                            .foregroundColor(.blue)
                        }
                        .onTapGesture {
                            
                            let increment = currentTrack.loopsToLevel[index] + 1
                            let incrementModulo = increment % loopLengthLocal.count
                            
                            clipLetters[index] = incrementModulo
                            currentTrack.loopsToLevel[index] = incrementModulo
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
