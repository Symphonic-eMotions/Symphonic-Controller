//
//  MidiClipsInFile.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 11/04/2023.
//

import SwiftUI

struct MidiClipsInFileView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    @Binding var loopLengthLocal: [Double]
    //This is shared status of the clips
    @Binding var clipLetters: [String:[Int]]
//    @State var clipLetterLocal: [Int]
    @State var clipLength: Int
    @State var isPlaying: [Bool]
    @Binding var updateView: Int
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        loopLengthLocal: Binding<[Double]>,
        clipLetters: Binding<[String:[Int]]>,
        updateView: Binding<Int>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _loopLengthLocal = loopLengthLocal
        _clipLetters = clipLetters
//        _clipLetterLocal = State(initialValue: currentTrack.loopLength.map{Int($0)})
        _clipLength = State(initialValue: Int(currentTrack.loopLength.first ?? 16))
        _isPlaying = State(initialValue: Array(repeating: false, count: currentTrack.loopLength.count))
        _updateView = updateView
    }
    
    var body: some View {
        
//        MidiFileView(
//            setInfoModel: setInfoModel,
//            currentTrack: currentTrack,
//            trackId: trackId
//        )
        
        //MIDI clips in file
        HStack() {
            
            VStack{
                
                Text("MIDI clips in file")
                    .frame(width: columnWidth, alignment: .leading)
                
                HStack{
                    //Remove clip button
                    Button("-") {
                        if (loopLengthLocal.count) > 1 {
                            
                            let oldClip: Int = clipLetters[trackId]!.last!
                            //Mutate in file databse
                            currentTrack.loopLength.removeLast()
                            //Binding structure
                            clipLetters[trackId]!.removeLast()
                            //Interface
                            loopLengthLocal.removeLast()
                            //Midiclip player
                            isPlaying.removeLast()
                                                        
                            //Replace clip in level
                            for (i, m) in currentTrack.loopsToLevel.enumerated() {
                                if m == oldClip {
                                    currentTrack.loopsToLevel[i] = currentTrack.loopsToLevel.first!
                                }
                            }
                            //Remove clip from midi clip grid
                            for (i, m) in currentTrack.loopsToGrid.enumerated() {
                                if m == oldClip {
                                    currentTrack.loopsToGrid[i] = currentTrack.loopsToGrid.first!
                                }
                            }
                            updateView += 1
                        }
                    }
                    .disabled(loopLengthLocal.count == 1)
                    .font(.system(size: 35))
                    
                    //Add clip button
                    Button("+") {
                        currentTrack.loopLength.append(16)
                        loopLengthLocal.append(16)
                        isPlaying.append(false)
                        clipLetters[trackId]!.append(clipLetters[trackId]!.count)
                        updateView += 1
                    }
                    .font(.system(size: 35))
                }
            }
            ForEach(0..<loopLengthLocal.count, id: \.self) { index in
                
                VStack {
                    if let letter: String = AppUtils.letterForNumber(index) {
                        
                        Image(systemName: isPlaying[index] ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 30)
                        .padding(.vertical, 5.0)
                        .padding(.horizontal, 5.0)
                        .background(Color.accentColor)
                        .cornerRadius(5.0)
                        .onTapGesture {
                            isPlaying[index].toggle()
                            setInfoModel.conductor.copyMidiSingleTrack(trackId: trackId, nextVariation: index, loopLength: currentTrack.loopLength)
                            setInfoModel.conductor.previewSingleTrack(trackId: trackId)
                        }
                        
                        ZStack{
                            MidiClipName(value: letter)
                        }
                    }
                }
            }
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
