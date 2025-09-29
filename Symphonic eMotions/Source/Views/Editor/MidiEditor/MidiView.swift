//
//  MidiView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/05/2024.
//

import SwiftUI

struct MidiView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var chords: [ChordEntry]
    var trackId: String

    @State private var selectedChord: Chord
    @State private var selectedOctave: Int
    @State private var selectedLength: Length
    @State private var strum: Double
    @State private var durationFactor: Double
    @State private var selectedOption: ChordOption
    @State private var editMode = EditMode.inactive

    @State private var isPlaying: Bool = false

    private var midiFileModel = MidiFileModel()
    @State var setTrackName: String

    // Expliciete initializer
    init(
        trackId: String,
        setInfoModel: SetInfoModel,
        chords: Binding<[ChordEntry]>
    ) {
        self.trackId = trackId
        self.setInfoModel = setInfoModel
        _chords = chords

        // Initialiseren van de state-variabelen met waarden van chords.first
        if let firstChord = chords.wrappedValue.first {
            _selectedChord = State(initialValue: firstChord.chord)
            _selectedOctave = State(initialValue: firstChord.octave)
            _selectedLength = State(initialValue: firstChord.length)
            _strum = State(initialValue: firstChord.strum)
            _durationFactor = State(initialValue: firstChord.durationFactor)
            _selectedOption = State(initialValue: firstChord.option)
        } else {
            _selectedChord = State(initialValue: .C)
            _selectedOctave = State(initialValue: 3)
            _selectedLength = State(initialValue: .whole)
            _strum = State(initialValue: 0.01)
            _durationFactor = State(initialValue: 0.95)
            _selectedOption = State(initialValue: .none)
        }

        _setTrackName = State(initialValue: "\(setInfoModel.setInfoLocalState.setName)_\(trackId)")
    }

    var body: some View {
        VStack {
            HStack {
                Picker("Chord", selection: $selectedChord) {
                    ForEach(Chord.allCases, id: \.self) { chord in
                        Text(chord.description).tag(chord)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Picker("Octave", selection: $selectedOctave) {
                    ForEach(1 ..< 8) { octave in
                        Text("\(octave)").tag(octave)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Picker("Length", selection: $selectedLength) {
                    ForEach(Length.allCases, id: \.self) { length in
                        Text(length.rawValue).tag(length)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Button(action: addChord) {
                    Text("Add Chord")
                }
            }
            .padding()

            Picker("Chord Option", selection: $selectedOption) {
                Text("None").tag(ChordOption.none)
                Text("Add Second Note as Fourth").tag(ChordOption.addSecondNoteAsFourth)
                Text("Add Seventh").tag(ChordOption.addSeventh)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedOption) { newValue in
                updateChordOptions(newValue)
            }

            HStack {
                Text("Strum \(self.strum, specifier: "%.2f")")
                Slider(value: Binding(
                    get: { self.strum },
                    set: { newValue in
                        self.strum = newValue
                        self.updateStrumValues(newValue)
                    }
                ), in: 0.01 ... (selectedLength.maxStrum), step: 0.01)
            }
            .padding(.horizontal, 40)

            HStack {
                Text("Duration \(self.durationFactor, specifier: "%.2f")")
                Slider(value: Binding(
                    get: { self.durationFactor },
                    set: { newValue in
                        self.durationFactor = newValue
                        self.updateDurationValues(newValue)
                    }
                ), in: 0.01 ... 0.99, step: 0.01)
            }
            .padding(.horizontal, 40)

            List {
                ForEach(chords) { entry in
                    HStack {
                        Text("\(entry.chord.description) \(entry.octave) - \(entry.length.rawValue)")
                        Spacer()
                        Button(action: {
                            removeChord(entry)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onMove(perform: move)
            }
            .environment(\.editMode, $editMode)

            HStack {
                if isPlaying {
                    Button(action: stopMIDIFile) {
                        Text("Stop MIDI")
                            .foregroundColor(.orange)
                    }
                    .padding()
                } else {
                    Button(action: createMIDIFile) {
                        Text("Create MIDI File")
                    }
                    .padding()
                }
                Button(action: clearChords) {
                    Text("Clear All")
                        .foregroundColor(.red)
                }
                .padding()
            }
        }
        .navigationBarItems(trailing: EditButton())
    }

    private func addChord() {
        let newEntry = ChordEntry(
            chord: selectedChord,
            octave: selectedOctave,
            length: selectedLength,
            strum: strum,
            durationFactor: durationFactor,
            option: selectedOption
        )
        chords.append(newEntry)
    }

    private func removeChord(_ chord: ChordEntry) {
        if let index = chords.firstIndex(of: chord) {
            chords.remove(at: index)
        }
    }

    private func clearChords() {
        chords.removeAll()
    }

    private func createMIDIFile() {
        midiFileModel.createMIDIFile(
            chords: chords,
            setTrackName: setTrackName,
            setPath: setInfoModel.setSettings.filesPath,
            bpm: setInfoModel.setSettings.bpm
        ) { _ in
            self.isPlaying = true
        }
        setInfoModel.setSettings.tracks[trackId]?.chordEntries = chords
        setInfoModel.setSettings.tracks[trackId]?.midiFile = setTrackName
    }

    private func stopMIDIFile() {
        midiFileModel.stopPlaying { _ in
            self.isPlaying = false
        }
    }

    private func updateStrumValues(_ newValue: Double) {
        for index in chords.indices {
            chords[index].strum = newValue
        }
    }

    private func updateDurationValues(_ newValue: Double) {
        for index in chords.indices {
            chords[index].durationFactor = newValue
        }
    }

    private func updateChordOptions(_ newValue: ChordOption) {
        for index in chords.indices {
            chords[index].option = newValue
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        chords.move(fromOffsets: source, toOffset: destination)
    }
}

// struct MidiView_Previews: PreviewProvider {
//    static var previews: some View {
//        MidiView(chords: <#Binding<[ChordEntry]>#>)
//    }
// }
