//
//  SoundSourceView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 15/06/2023.
//

import SwiftUI

struct SoundSourceView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String
    
    //Bindings
    @Binding var showEditorPart: EditorParts
    @Binding var soundSources: [String: InstrumentsSet.Track.InstrumentType]
    
    //States
    @State var soundSource: InstrumentsSet.Track.InstrumentType
    @State private var infoVisibility: [String: Bool] = [:]
    @State var audioFiles: [InstrumentsSet.Track.AudioFile]
    @State var selectedExsFile: ExsFiles
    @State var selectedExsFileMemory: ExsFiles
    @State private var hasChanged = false
    
    //Audio files
    @State var importing = false
    @State var isNewAudio: Bool = false
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        soundSources: Binding<[String : InstrumentsSet.Track.InstrumentType]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _soundSources = soundSources
        _soundSource = State(initialValue: soundSources[trackId].wrappedValue ?? .exsSampler)
        _audioFiles = State(initialValue: currentTrack.audioFiles)
        _selectedExsFile = State(initialValue: currentTrack.exsFile)
        _selectedExsFileMemory = State(initialValue: currentTrack.exsFile)
    }
    
    private func toggleInfoVisibility(for key: String) {
        infoVisibility[key, default: false].toggle()
    }
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack(){
                
                //Sound Source
                ZStack {
                    
                    Rectangle()
                        .frame(width: 130, height: 34)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        .background( showEditorPart == .sound ? .clear : color )
                    
                    Text("Sound source")
                        .frame(width: 130, height: 34)
                    
                }
                .frame(width: columnWidth, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        showEditorPart = .sound
                    }
                }
                
                Picker("Sources of sound", selection: $soundSource) {
                    let workingTypes: [InstrumentsSet.Track.InstrumentType] = [.exsSampler,.audioBuffer]
                    ForEach(workingTypes, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(.segmented)
//                .frame(height: 100)
                .onChange(of: soundSource) { type in
                    withAnimation {
                        //Store to file
                        currentTrack.instrumentType = type
                        //Binding
                        soundSources[trackId] = type
                        //State
                        soundSource = type
                    }
                }
            }
            if soundSource == .exsSampler {
                
                HStack {
                    
                    Text("EXS preset")
                        .frame(width: columnWidth, alignment: .leading)
                    
                    let excludedCases: [ExsFiles] = [.trigger]
                    Picker("Presets", selection: $selectedExsFile) {
                        ForEach(ExsFiles.allCases.filter { !excludedCases.contains($0) }, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width:300, height: 100)
                    .onChange(of: selectedExsFile) { type in
                        withAnimation {
                            
                            hasChanged = (type != selectedExsFileMemory)
                            
                            //to file
                            currentTrack.exsFile = type
                        }
                    }
                    
//                    Button(action: {
//                        withAnimation {
//                            selectedExsFile = selectedExsFileMemory
//                            hasChanged = false
//                        }
//                    }) {
//                        Image(systemName: "arrow.uturn.backward.circle")
//                            .font(.title)
//                            .foregroundColor( hasChanged ? .blue : .gray)
//                    }
//                    .disabled(!hasChanged)
                    
                    if hasChanged {
                        Text("Please save and re-open set")
                            .foregroundColor(.red)
                    }
                }
            }
            else if soundSource == .audioBuffer {
                
                HStack(){
                    
                    //Info about file locations
                    HStack (spacing: 30) {
                        //Current audio files
                        //Button new audio file
                        //Button more info
                        VStack(alignment: .leading, spacing: 20){
                            
                            HStack{
                                Text("Audio files")
                                HStack{
                                    //Notice we need to reload
                                    if isNewAudio {
                                        //Notice we need to reload engine
                                        Text(NSLocalizedString("Save and reopen", comment: ""))
                                            .foregroundStyle(.red)
                                    }
                                    
                                    //Button new audio file
                                    Button(action: {importing.toggle()}, label: {
                                        Text("Add audio file")
                                    })
                                    
                                    //Info about where to keep the audio files
                                    Button(action: {
                                        toggleInfoVisibility(for: "addAudio")
                                    }) {
                                        Image(systemName: "info.circle")
                                            .font(.title)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            //Current audio files
                            ForEach(audioFiles) { audioFile in
                                VStack(alignment: .leading) {
                                    HStack{
                                        Text("\(audioFile.fileName).\(audioFile.fileExtension)")
                                        
                                        if let index = audioFiles.firstIndex(where: { $0.id == audioFile.id }) {
                                            
                                            let binding = Binding<Int>(
                                                get: {
                                                    Int(audioFile.lengthInBeats)
                                                },
                                                set: { newValue in
                                                    currentTrack.audioFiles[index].lengthInBeats = Double(newValue)
                                                }
                                            )

                                            TextField("Length in Beats", value: binding, formatter: NumberFormatter())
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .padding()
                                                .frame(width: 80)
                                        }
                                        
                                        Text("Beats")
                                        
                                        Spacer()
                                        
                                        Button("-") {
                                            //From state
                                            if let index = audioFiles.firstIndex(where: { $0.id == audioFile.id }) {
                                                audioFiles.remove(at: index)
                                            }
                                            
                                            //From file
                                            if let index = setInfoModel.setSettings.tracks[trackId]?.audioFiles.firstIndex(where: { $0.id == audioFile.id }) {
                                                setInfoModel.setSettings.tracks[trackId]?.audioFiles.remove(at: index)
                                            }
                                        }
                                        .font(.system(size: 45))
                                        .foregroundColor(.red)
                                    }
                                }
                                .frame(height: 60)
                            }

                        }
                        
                        if infoVisibility["addAudio", default: false] {
                            
                            if let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
                                Text("Keep .wav and .aiff files in \"\(displayName)/\(setInfoModel.setSettings.filesPath)/\"")
                            }
                        }
                    }
                    .fileImporter(isPresented: $importing, allowedContentTypes: [.wav,.aiff]) { file in
                        do {
                            let fileUrl: URL = try file.get()
                            let folderAndFileName = "\(setInfoModel.setSettings.filesPath)/\(fileUrl.lastPathComponent)"
                            
                            let fileName = fileUrl.deletingPathExtension().lastPathComponent
                            let fileExtension = fileUrl.pathExtension
                            
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
                            //Create a new AudioFile object
                            //File name input
//                            let midiNote = setInfoModel.conductor.midiNoteNumberFromFileName(fileName) ?? 48
                            let lengthInBeats = setInfoModel.conductor.lengthInBeatsFromFileName(fileName: fileName) ?? 4
                            let newAudioFile = InstrumentsSet.Track.AudioFile(
                                fileName: fileName,
                                fileExtension: fileExtension,
                                lengthInBeats: lengthInBeats,
                                source: .user
                            )
                            
                            setInfoModel.setSettings.tracks[trackId]?.audioFiles.append(newAudioFile)
                            audioFiles.append(newAudioFile)
                            isNewAudio = true
                            
                            print("Loaded Audio file: \(fileName)")
                            
                        } catch{
                            
                            isNewAudio = false
                            
                            print ("SoundSourceView error reading: \(error.localizedDescription)")
                        }
                    }
                    
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}

