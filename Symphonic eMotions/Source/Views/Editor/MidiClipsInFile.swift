//
//  MidiClipsInFile.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 11/04/2023.
//

import SwiftUI

struct MidiClipsInFile: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    @Binding var loopLengthLocal: [Double]
    @Binding var clipLetters: [String:[Int]]
    @State var clipLength: Int
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        loopLengthLocal: Binding<[Double]>,
        clipLetters: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _loopLengthLocal = loopLengthLocal
        _clipLetters = clipLetters
        _clipLength = State(initialValue: Int(currentTrack.loopLength.first ?? 16))
    }
    
    var body: some View {
        
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
            //Remove clip button
            Button("-") {
                if (loopLengthLocal.count) > 1 {
                    
                    let oldLength: Int = currentTrack.loopLength.count-1
                    //Mutate in file databse
                    currentTrack.loopLength.removeLast()
                    //Binding structure
                    clipLetters[trackId]!.removeLast()
                    //Interface
                    loopLengthLocal.removeLast()
                    
                    let newLength: Int = currentTrack.loopLength.count-1
                    
                    //Remove clip from loopsToLevel
                    if currentTrack.loopsToLevel.contains(oldLength){
                        currentTrack.loopsToLevel = currentTrack.loopsToLevel.map {
                            $0 == oldLength ? newLength: $0
                        }
                    }
                    //Remove clip from loopsToGrid
                    if currentTrack.loopsToGrid.contains(oldLength){
                        currentTrack.loopsToGrid = currentTrack.loopsToGrid.map {
                            $0 == oldLength ? newLength: $0
                        }
                    }
                }
            }
            .disabled(loopLengthLocal.count == 1)
            .font(.system(size: 35))
            
            //Add clip button
            Button("+") {
                currentTrack.loopLength.append(16)
                loopLengthLocal.append(16)
                clipLetters[trackId]!.append(clipLetters[trackId]!.count)
            }
            .font(.system(size: 35))
        }
        .onAppear {
            // Set initial value of syncedValue to value from observed object
            loopLengthLocal = setInfoModel.setSettings.tracks[trackId]!.loopLength
        }
        .onChange(of: setInfoModel.setSettings.tracks[trackId]!.loopLength) { newValue in
            // Update syncedValue when value in observed object changes
            loopLengthLocal = newValue
        }
        
        //MIDI clip lengths, this value is placed on all loopLength indexes needed for clip selection
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
    }
}
