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
    @Binding var midiClips: [String: [Double]]
    @Binding var midiClipLetters: [String:[Int]]
    @Binding var midiClipsLevels: [String:[Int]]
    @Binding var midiClipspositions: [String:[Int]]
    
    //States
    @State var noteSource: NoteSource
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        noteSources: Binding<[String: NoteSource]>,
        midiClips: Binding<[String: [Double]]>,
        midiClipLetters: Binding<[String:[Int]]>,
        midiClipsLevels: Binding<[String:[Int]]>,
        midiClipspositions: Binding<[String:[Int]]>
        
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _noteSources = noteSources
        _midiClips = midiClips
        _midiClipLetters = midiClipLetters
        _midiClipsLevels = midiClipsLevels
        _midiClipspositions = midiClipspositions
        _noteSource = State(initialValue: noteSources[trackId].wrappedValue!)
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
                    }
                }
            }
            
            if noteSource == .noteNumbers {
                
            }
            else if noteSource == .midiFile {
                
                MidiClipsView(
                    setInfoModel: setInfoModel,
                    currentTrack: currentTrack,
                    trackId: trackId,
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
