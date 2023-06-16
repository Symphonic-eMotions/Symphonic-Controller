//
//  MidiClipsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 15/06/2023.
//

import SwiftUI

struct MidiClipsView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    //Bindings
    @Binding var midiClips: [String:[Double]]
    @Binding var midiClipLetters: [String:[Int]]
    @Binding var midiClipsLevels: [String:[Int]]
    @Binding var midiClipspositions: [String:[Int]]
    
    //Sate
    @State var isPlaying: [Bool]
    @State var clipLength: Int
    
    //Midi files
    @State var importing = false
    @State var isNewMidi: Bool = false
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        midiClips: Binding<[String:[Double]]>,
        midiClipLetters: Binding<[String:[Int]]>,
        midiClipsLevels: Binding<[String:[Int]]>,
        midiClipspositions: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _midiClips = midiClips
        _midiClipLetters = midiClipLetters
        _midiClipsLevels = midiClipsLevels
        _midiClipspositions = midiClipspositions
        _isPlaying = State(
            initialValue: Array(
                repeating: false,
                count: currentTrack.loopLength.count
            )
        )
        _clipLength = State(initialValue: Int(currentTrack.loopLength.first ?? 16))
    }
    
    var body: some View {
        
        //MIDI clips in file
        HStack() {
            
            HStack{
                
                Text("MIDI clips")
                    .frame(width: columnWidth, alignment: .leading)
                
            }
            
            HStack{
                
                //Remove clip button
                Button("-") {
                    if (midiClips.count) > 1 {
                        
                        let oldClip: Int = midiClipLetters[trackId]!.last!
                        //Mutate in file databse
                        currentTrack.loopLength.removeLast()
                        //Binding structure
                        midiClipLetters[trackId]!.removeLast()
                        midiClips[trackId]!.removeLast()
                        //Midiclip player
                        isPlaying.removeLast()
                        
                        //Replace clip in level
                        for (i, m) in currentTrack.loopsToLevel.enumerated() {
                            if m == oldClip {
                                //Store to file
                                currentTrack.loopsToLevel[i] = currentTrack.loopsToLevel.first!
                                //Binding
                                midiClipsLevels[trackId]![i] = currentTrack.loopsToLevel.first!
                            }
                        }
                        //Remove clip from midi clip grid
                        for (i, m) in currentTrack.loopsToGrid.enumerated() {
                            if m == oldClip {
                                //Store to file
                                currentTrack.loopsToGrid[i] = currentTrack.loopsToGrid.first!
                                //Binding
                                midiClipspositions[trackId]![i] = currentTrack.loopsToGrid.first!
                            }
                        }
                    }
                }
                .disabled(midiClips.count == 1)
                .font(.system(size: 45))
                
                //Add clip button
                Button("+") {
                    
                    currentTrack.loopLength.append(16)
                    //Binding structure
                    midiClipLetters[trackId]!.append(midiClipLetters[trackId]!.count)
                    midiClips[trackId]!.append(16)
                    isPlaying.append(false)
                }
                .font(.system(size: 45))
            }
            
            ForEach(0..<midiClipLetters[trackId]!.count, id: \.self) { index in
                
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
            }
        }
        
        //MIDI clip length
        HStack(){
            
            Text("MIDI Clip length")
                .frame(width: columnWidth, alignment: .leading)
            
            TextField("Cliplength", text: Binding(
                get:{ String(clipLength) },
                set:{ if let value = Double($0) {
                    //State
                    clipLength = Int(value)
                    //Save to file
                    currentTrack.loopLength = Array(repeating: value, count: currentTrack.loopLength.count)
                }}
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 40, height: 25)
            
            Text("beats")
                .frame(width: columnWidth, alignment: .leading)
        }
        
        //MIDI file
        HStack(){
            
            Text("MIDI File")
                .frame(width: columnWidth, alignment: .leading)
            
            HStack (spacing: 30) {
                
                Text(currentTrack.midiFile)
                    .padding()
                
                if isNewMidi {
                    Text(NSLocalizedString("Save and reopen", comment: ""))
                        .foregroundStyle(.red)
                }
                else{
                    Button(action: {importing.toggle()}, label: {
                        Text("Replace current MIDI file")
                    })
                }
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.midi]) { file in
                do {
                    let fileUrl: URL = try file.get()
                    let folderAndFileName = "\(setInfoModel.setSettings.filesPath)/\(fileUrl.lastPathComponent)"
                    let fileName = "\(fileUrl.lastPathComponent)"
                    
                    // define destination URL in your app's documents directory
                    let documentsDirectory = try FileManager.default.url(
                        for: .documentDirectory,
                         in: .userDomainMask,
                         appropriateFor: nil,
                         create: false
                    )
                    let destinationUrl = documentsDirectory.appendingPathComponent(folderAndFileName)
                    
                    // Ensure that file exists at the destination URL
                    guard FileManager.default.fileExists(atPath: destinationUrl.path) else {
                        throw NSError(domain: NSCocoaErrorDomain,
                                      code: NSFileReadNoSuchFileError,
                                      userInfo: [NSFilePathErrorKey: destinationUrl.path])
                    }
                    
                    // Load the MIDI file into the sequencer
                    setInfoModel.conductor.trackSequencers[trackId]?.loadMIDIFile(fromURL: destinationUrl)
                    setInfoModel.conductor.trackSequencersMemory[trackId]?.loadMIDIFile(fromURL: destinationUrl)
                    
                    setInfoModel.setSettings.tracks[trackId]?.midiFile = fileName
                    
                    isNewMidi = true
                    
                    print("Loaded MIDI file: \(fileName)")
                    
                } catch{
                    
                    isNewMidi = false
                    
                    print ("MidiClipsView error reading: \(error.localizedDescription)")
                }
            }
            
            //            Text(currentTrack.midiFile)
            //                .frame(width: columnWidth, alignment: .leading)
        }
    }
}
