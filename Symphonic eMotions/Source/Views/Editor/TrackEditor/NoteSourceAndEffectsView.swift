//
//  NoteSourceAndEffectsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import SwiftUI

struct NoteSourceAndEffectsView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    var trackId: String

    @Binding var showEditorPart: EditorParts
    @Binding var noteSources: [String: NoteSource]
    @Binding var chordEntries: [String: [ChordEntry]]
    @Binding var soundSources: [String: InstrumentsSet.Track.InstrumentType]
    @Binding var midiClips: [String: [Double]]
    @Binding var midiClipLetters: [String: [Int]]
    @Binding var midiClipsLevels: [String: [Int]]
    @Binding var midiClipspositions: [String: [Int]]
    @Binding var noteNumbers: [String: [Int]]
    @Binding var noteNumberLetters: [String: [Int]]
    @Binding var availableVariationTypes: [String: [VariationType]]

    @Binding var showTrackEffect: Bool
    @Binding var showChordEntries: Bool

    @State var noteSource: NoteSource
    @State var countedParts: Int
    @State var isPlaying: [Bool]

    var trackEffectViewObject: [TrackEffect]
    @State var trackEffectState: [[Float]]

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        noteSources: Binding<[String: NoteSource]>,
        chordEntries: Binding<[String: [ChordEntry]]>,
        soundSources: Binding<[String: InstrumentsSet.Track.InstrumentType]>,
        midiClips: Binding<[String: [Double]]>,
        midiClipLetters: Binding<[String: [Int]]>,
        midiClipsLevels: Binding<[String: [Int]]>,
        midiClipspositions: Binding<[String: [Int]]>,
        noteNumbers: Binding<[String: [Int]]>,
        noteNumberLetters: Binding<[String: [Int]]>,
        availableVariationTypes: Binding<[String: [VariationType]]>,

        showTrackEffect: Binding<Bool>,
        showChordEntries: Binding<Bool>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId

        _showEditorPart = showEditorPart
        _noteSources = noteSources
        _chordEntries = chordEntries
        _soundSources = soundSources
        _midiClips = midiClips
        _midiClipLetters = midiClipLetters
        _midiClipsLevels = midiClipsLevels
        _midiClipspositions = midiClipspositions
        _noteNumbers = noteNumbers
        _noteNumberLetters = noteNumberLetters
        _availableVariationTypes = availableVariationTypes

        _showTrackEffect = showTrackEffect
        _showChordEntries = showChordEntries

        _noteSource = State(initialValue: noteSources.wrappedValue[trackId]!)
        _countedParts = State(initialValue: currentTrack.parts.count)

        _isPlaying = State(initialValue: Array(repeating: false, count: currentTrack.loopLength.count))

        trackEffectViewObject = TrackEffectsHelper.trackEffectViewObject(trackSettings: currentTrack)
        trackEffectState = TrackEffectsHelper.trackEffectsStateObject(viewObject: trackEffectViewObject)
    }

    let columnWidth: CGFloat = 150
    let color: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading) {
            Divider()

            // Note Source
            HStack {
                ZStack {
                    Rectangle()
                        .frame(width: 120, height: 34)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        .background(showEditorPart == .source ? .clear : color)

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
                        // Store to file
                        currentTrack.noteSource = type
                        // Binding
                        noteSources[trackId] = type
                        // State
                        noteSource = type

                        availableVariationTypes[trackId] = [.variationByLevel, .variationByPosition]
                    }
                }
            }

            // Sheets
            HStack {
                HStack {
                    // Left column is empty
                    Text("")
                        .frame(width: columnWidth)

                    // Preview button and effect interface right column
                    ZStack {
                        Rectangle()
                            .frame(width: 130, height: 34)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background(showTrackEffect ? .clear : color)

                        Text("Preview")
                            .frame(width: 130, height: 34)
                    }
                    .onTapGesture {
                        withAnimation {
                            showTrackEffect.toggle()
                        }
                    }
                    .padding(.top, 40)

                    // Chord generator / Score
                    ZStack {
                        Rectangle()
                            .frame(width: 130, height: 34)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background(showChordEntries ? .clear : color)

                        Text("Chords")
                            .frame(width: 130, height: 34)
                    }
                    .onTapGesture {
                        withAnimation {
                            showChordEntries.toggle()
                        }
                    }
                    .padding(.top, 40)
                }
                // Preview Sheet
                .sheet(isPresented: $showTrackEffect) {
                    // Players for MIDI clips in file
                    if noteSources[trackId] == .midiFile {
                        HStack {
                            ForEach(0 ..< midiClipLetters[trackId]!.count, id: \.self) { index in
                                let clipLetter: String = AppUtils.letterForNumber(index) ?? "-"

                                HStack {
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
                                    // Toggle play state
                                    isPlaying[index].toggle()

                                    // Copy correct midi clip part to play head sequencer
                                    setInfoModel.conductor.copyMidiSingleTrack(
                                        trackId: trackId,
                                        nextVariation: index,
                                        loopLength: currentTrack.loopLength
                                    )

                                    // Start playing the midi file
                                    setInfoModel.conductor.previewSingleTrack(
                                        trackId: trackId,
                                        soundSource: soundSources[trackId]!
                                    )
                                }
                            }
                        }
                        .padding(.top)
                    }

                    if noteSources[trackId] == .noteNumbers {
                        // Players for Note numbers
                        HStack {
                            // Play stop current note
                            ForEach(0 ..< noteNumbers[trackId]!.count, id: \.self) { index in
                                let letter: String = AppUtils.midiNoteName(for: self.noteNumbers[trackId]![index])

                                HStack {
                                    Text("\(letter)")
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
                                    setInfoModel.conductor.playNoteNumberSingleTrack(
                                        trackId: trackId,
                                        soundSource: soundSources[trackId]!,
                                        noteNumber: noteNumbers[trackId]![index],
                                        noteOn: isPlaying[index]
                                    )

                                    isPlaying[index].toggle()
                                }
                            }
                        }
                        .padding(.top)
                    }

                    // Effect sliders
                    TrackEffectView(
                        setInfoModel: setInfoModel,
                        currentTrack: currentTrack,
                        trackId: trackId,
                        showTrackEffect: $showTrackEffect
                    )
                    .padding(.bottom)
                }
                // Stop notes on sheet release
                .onChange(of: showTrackEffect) { newValue in
                    if !newValue { // if the sheet is dismissed
                        setInfoModel.conductor.stopAllNoteNumbers(trackId: trackId)
                    }
                }
                // Chords sheet
                .sheet(isPresented: $showChordEntries) {
                    MidiView(
                        trackId: trackId,
                        setInfoModel: setInfoModel,
                        chords: Binding(
                            get: { chordEntries[trackId] ?? [] },
                            set: { chordEntries[trackId] = $0 }
                        )
                    )
                }
                // Stop notes on sheet release
                .onChange(of: showChordEntries) { newValue in
                    if !newValue { // if the sheet is dismissed
                        setInfoModel.conductor.stopAllNoteNumbers(trackId: trackId)
                    }
                }
            }

            // Note Numbers
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

            // Midi File with preview effect sheet
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
