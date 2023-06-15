//
//  MidiClipsInFileViewOrg.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 11/04/2023.
//

import SwiftUI

struct MidiClipsInFileViewOrg: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    //Bindings
    @Binding var midiClips: [String:[Double]]
    @Binding var midiClipLetters: [String:[Int]]
    
    //States
    @State var clipLength: Int
    @State var midiClipsLocal: [Double]
    @State var isPlaying: [Bool]
    
    //Midi files
    @State var imported = false
    @State var urlString: String?
//    @State var fileUrl: URL = URL("init")
    
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        midiClips: Binding<[String:[Double]]>,
        midiClipLetters: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _midiClips = midiClips
        _midiClipLetters = midiClipLetters
        _clipLength = State(initialValue: Int(currentTrack.loopLength.first ?? 16))
        _midiClipsLocal = State(initialValue: currentTrack.loopLength)
        _isPlaying = State(initialValue: Array(repeating: false, count: currentTrack.loopLength.count))

        
//        _urlString = State(initialValue: currentTrack.midiFile)
    }
    
    var body: some View {
        
        //MidiFile
        HStack(){
            
            Text("MIDI File")
                .frame(width: columnWidth, alignment: .leading)
            
            VStack (spacing: 30) {
                Button(action: {imported.toggle()}, label: {
                    Text("Select MIDI file")
                })
                if let theUrl = urlString {
                    
//                    Text("file url is \(theUrl)")
                    
                }
            }
            .fileImporter(isPresented: $imported, allowedContentTypes: [.midi]) { res in
                do {
                    
                    let fileUrl: URL = try res.get()
                    
                    urlString = fileUrl.absoluteString
                    setInfoModel.conductor.trackSequencers[trackId]?.loadMIDIFile(fromURL: fileUrl)
                    
//                    print("---> fileUrl: \(urlString ?? "not loaded")")
                } catch{
                    print ("error reading: \(error.localizedDescription)")
                }
            }
            
            Text(currentTrack.midiFile)
                .frame(width: columnWidth, alignment: .leading)
        }
        
        
        //MIDI clips in file
        HStack() {
            
            VStack{
                
                Text("MIDI clips in file")
                    .frame(width: columnWidth, alignment: .leading)
                
                HStack{
                    //Remove clip button
                    Button("-") {
                        if (midiClipsLocal.count) > 1 {
                            
                            let oldClip: Int = midiClipLetters[trackId]!.last!
                            //Mutate in file databse
                            currentTrack.loopLength.removeLast()
                            //Binding structure
                            midiClipLetters[trackId]!.removeLast()
                            //Interface
                            midiClipsLocal.removeLast()
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
                        }
                    }
                    .disabled(midiClipsLocal.count == 1)
                    .font(.system(size: 35))
                    
                    //Add clip button
                    Button("+") {
                        currentTrack.loopLength.append(16)
                        midiClipsLocal.append(16)
                        isPlaying.append(false)
                        midiClipLetters[trackId]!.append(midiClipLetters[trackId]!.count)
                    }
                    .font(.system(size: 35))
                }
            }
            ForEach(0..<midiClipsLocal.count, id: \.self) { index in
                
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
//            loopLengthLocal = setInfoModel.setSettings.tracks[trackId]!.loopLength
        }
        .onChange(of: setInfoModel.setSettings.tracks[trackId]!.loopLength) { newValue in
            // Update syncedValue when value in observed object changes
//            loopLengthLocal = newValue
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
