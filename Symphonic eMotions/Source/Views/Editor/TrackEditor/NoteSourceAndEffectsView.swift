//
//  NoteSourceView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import SwiftUI

struct NoteSourceAndEffectsView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String

    //Bindings
    @Binding var showEditorPart: EditorParts
    @Binding var noteSources: [String: NoteSource]
    @Binding var soundSources: [String: InstrumentsSet.Track.InstrumentType]
    @Binding var midiClips: [String: [Double]]
    @Binding var midiClipLetters: [String:[Int]]
    @Binding var midiClipsLevels: [String:[Int]]
    @Binding var midiClipspositions: [String:[Int]]
    @Binding var noteNumbers: [String: [Int]]
    @Binding var noteNumberLetters: [String: [Int]]
    @Binding var availableVariationTypes: [String: [VariationType]]
    
    @Binding var showTrackEffect: Bool
    
    //States
    @State var noteSource: NoteSource
    @State var countedParts: Int
//    @State var hasVelocity: Bool
    @State var isPlaying: [Bool]
    
    //Initialize effects on play preview to start with correct values send to effect parameters
    var trackEffectViewObject: [TrackEffect]
    @State var trackEffectState: [[Float]]
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        noteSources: Binding<[String: NoteSource]>,
        soundSources: Binding<[String: InstrumentsSet.Track.InstrumentType]>,
        midiClips: Binding<[String: [Double]]>,
        midiClipLetters: Binding<[String:[Int]]>,
        midiClipsLevels: Binding<[String:[Int]]>,
        midiClipspositions: Binding<[String:[Int]]>,
        noteNumbers: Binding<[String:[Int]]>,
        noteNumberLetters: Binding<[String:[Int]]>,
        availableVariationTypes: Binding<[String:[VariationType]]>,
        
        showTrackEffect: Binding<Bool>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        
        _showEditorPart = showEditorPart
        _noteSources = noteSources
        _soundSources = soundSources
        _midiClips = midiClips
        _midiClipLetters = midiClipLetters
        _midiClipsLevels = midiClipsLevels
        _midiClipspositions = midiClipspositions
        _noteNumbers = noteNumbers
        _noteNumberLetters = noteNumberLetters
        _availableVariationTypes = availableVariationTypes
        
        _showTrackEffect = showTrackEffect
        
        _noteSource = State(initialValue: noteSources[trackId].wrappedValue!)
        _countedParts = State(initialValue: currentTrack.parts.count)
        
        _isPlaying = State(
            initialValue: Array(
                repeating: false,
                count: currentTrack.loopLength.count
            )
        )
        
        self.trackEffectViewObject = TrackEffectsHelper.trackEffectViewObject(trackSettings: currentTrack)
        self.trackEffectState = TrackEffectsHelper.trackEffectsStateObject(viewObject: trackEffectViewObject)
        
//        let hasVelocityPart = currentTrack.parts.contains { (_, part) in
//            part.damperTarget.parameter == "velocity"
//        }
//        _hasVelocity = State(initialValue: hasVelocityPart)
    }
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            //Note Source
            HStack(){
                ZStack {
                    Rectangle()
                        .frame(width: 120, height: 34)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        .background( showEditorPart == .source ? .clear : color )
                    
                    Text("Note source")
                        .frame(width: 120, height: 34)
                    
                }
                .frame(width: columnWidth, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        showEditorPart = .source
                    }
                }
                
                Picker("Select source of notes", selection: $noteSource) {
                    ForEach(NoteSource.allCases, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: noteSource) { type in
                    withAnimation {
                        //Store to file
                        currentTrack.noteSource = type
                        //Binding
                        noteSources[trackId] = type
                        //State
                        noteSource = type
                        
//                        if type == .midiFile {
                            availableVariationTypes[trackId] = [.variationByLevel,.variationByPosition]
//                        }
//                        else{
//                            availableVariationTypes[trackId] = [.variationByLevel,.variationByPosition,.variationSequencial]
//                        }
                    }
                }
            }
            
            //Preview & Velocity
            HStack(){
                
                //Preview
                HStack {
                    //Left column is empty
                    Text("")
                    .frame(width: columnWidth, alignment: .leading)
                    .onTapGesture {
                        withAnimation {
                            showTrackEffect.toggle()
                        }
                    }
                    
                    //Show preview button in right column
                    ZStack {
                        
                        Rectangle()
                            .frame(width: 130, height: 34)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background( showTrackEffect ? .clear : color )
                        
                        Text("Preview")
                            .frame(width: 130, height: 34)
                    }
                    .onTapGesture {
                        withAnimation {
                            showTrackEffect.toggle()
                        }
                    }
                    .padding(.top)
                }
                .sheet(isPresented: $showTrackEffect) {
                    
                    //Players for MIDI clips in file
                    HStack() {
                        
                        ForEach(0..<midiClipLetters[trackId]!.count, id: \.self) { index in
                            
                            let clipLetter: String = AppUtils.letterForNumber(index) ?? "-"
                            
                            HStack{
                                
                                Text("\(clipLetter)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                
                                Image(systemName: isPlaying[index] ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 30)
                                    
                            }
                            .padding(.vertical, 5.0)
                            .padding(.horizontal, 5.0)
                            .background(Color.accentColor)
                            .cornerRadius(5.0)
                            .onTapGesture {
                                
                                //Toggle play status
                                isPlaying[index].toggle()
                                
                                //Copy correct midi clip part to play head sequencer
                                setInfoModel.conductor.copyMidiSingleTrack(
                                    trackId: trackId,
                                    nextVariation: index,
                                    loopLength: currentTrack.loopLength
                                )
                                
                                //Start playing the midi file
                                setInfoModel.conductor.previewSingleTrack(
                                    trackId: trackId,
                                    soundSource: soundSources[trackId]!
                                )
                            }
                        }
                    }
                    .padding(.top)
                    
                    //Effect sliders
                    TrackEffectView(
                        setInfoModel: setInfoModel,
                        currentTrack: currentTrack,
                        trackId: trackId,
                        showTrackEffect: $showTrackEffect
                    )
                    .padding(.bottom)
                    
                }
                
                //Velocity
//                Text("Velocity sensitive")
//
//
//                Toggle("", isOn: $hasVelocity)
//                .frame(width: 50)
//                .padding(.leading)
//                .disabled(hasVelocity && countedParts == 1)
//                .onChange(of: hasVelocity) { newValue in
//
//                    // Call the function when the toggle value changes
//                    if newValue == true {
//                        if let newPart = setInfoModel.addVelocityPart(
//                            velocitySensitive: newValue,
//                            trackId: trackId
//                        ) {
//                            currentTrack.parts[newPart.partId] = newPart
//                            setInfoModel.setSettings.tracks[trackId]?.parts[newPart.partId] = newPart
//                        }
//                    }
//                }
//
//                if hasVelocity && countedParts == 1 {
//                    Text(NSLocalizedString("One part", comment: ""))
//                }
            }
            
            //Note Numbers
            if noteSource == .noteNumbers {
                
                NoteNumberView(
                    setInfoModel: setInfoModel,
                    currentTrack: currentTrack,
                    trackId: trackId,
                    noteNumbers: $noteNumbers,
                    noteNumberLetters: $noteNumberLetters,
                    soundSources: $soundSources
                )
            }
            
            //Midi File with preview effect sheet
            else if noteSource == .midiFile {
                
                MidiClipsView(
                    setInfoModel: setInfoModel,
                    currentTrack: currentTrack,
                    trackId: trackId,
                    soundSources: $soundSources,
                    midiClips: $midiClips,
                    midiClipLetters: $midiClipLetters,
                    midiClipsLevels: $midiClipsLevels,
                    midiClipspositions: $midiClipspositions
                )
            }

        }
        .padding(.leading)
        .padding(.trailing)
    }
}
