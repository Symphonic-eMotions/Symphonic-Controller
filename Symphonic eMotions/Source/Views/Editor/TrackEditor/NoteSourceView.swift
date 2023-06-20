//
//  NoteSourceView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import SwiftUI

struct NoteSourceView: View {
    
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
    
    //States
    @State var noteSource: NoteSource
    @State var countedParts: Int
    @State var hasVelocity: Bool
    
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
        availableVariationTypes: Binding<[String:[VariationType]]>
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
        
        _noteSource = State(initialValue: noteSources[trackId].wrappedValue!)
        _countedParts = State(initialValue: currentTrack.parts.count)
        let hasVelocityPart = currentTrack.parts.contains { (_, part) in
            part.damperTarget.parameter == "velocity"
        }
        _hasVelocity = State(initialValue: hasVelocityPart)
    }
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
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
                        
                        if type == .midiFile {
                            availableVariationTypes[trackId] = [.variationByLevel,.variationByPosition]
                        }
                        else{
                            availableVariationTypes[trackId] = [.variationByLevel,.variationByPosition,.variationSequencial]
                        }
                    }
                }
            }
            
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
            
            HStack(){
                
                Text("Velocity sensitive")
                    .frame(width: columnWidth, alignment: .leading)
                
                Toggle("", isOn: $hasVelocity)
                .frame(width: 50)
                .padding(.leading)
                .disabled(hasVelocity && countedParts == 1)
                .onChange(of: hasVelocity) { newValue in
                    
                    // Call the function when the toggle value changes
                    if newValue == true {
                        if let newPart = setInfoModel.addVelocityPart(
                            velocitySensitive: newValue,
                            trackId: trackId
                        ) {
                            currentTrack.parts[newPart.partId] = newPart
                            setInfoModel.setSettings.tracks[trackId]?.parts[newPart.partId] = newPart
                        }
                    }
                }
                
                if hasVelocity && countedParts == 1 {
                    Text(NSLocalizedString("One part", comment: ""))
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
