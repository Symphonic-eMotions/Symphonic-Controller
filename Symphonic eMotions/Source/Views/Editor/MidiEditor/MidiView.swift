//
//  MidiView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/05/2024.
//

import SwiftUI
import AVFoundation

struct MidiView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var chords: [ChordEntry]
    var trackId: String
    
    @State private var selectedChord: Chord = .C
    @State private var selectedOctave: Int = 3
    @State private var selectedLength: Length = .whole
    @State private var strum: Double = 0.01
    @State private var durationFactor: Double = 0.95
    @State private var editMode = EditMode.inactive
    
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
        self._chords = chords
        self._setTrackName = State(initialValue: "\(setInfoModel.setInfoLocalState.setName)_\(trackId)")
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("Chord", selection: $selectedChord) {
                    ForEach(Chord.allCases, id: \.self) { chord in
                        Text(chord.rawValue).tag(chord)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Picker("Octave", selection: $selectedOctave) {
                    ForEach(1..<8) { octave in
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
            
            HStack {
                Text("Strum \(self.strum, specifier: "%.2f")")
                Slider(value: Binding(
                    get: { self.strum },
                    set: { newValue in
                        self.strum = newValue
                        self.updateStrumValues(newValue)
                    }
                ), in: 0.01...(selectedLength.maxStrum), step: 0.01)
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
                ), in: 0.01...0.99, step: 0.01)
            }
            .padding(.horizontal, 40)
            
            List {
                ForEach(chords) { entry in
                    HStack {
                        Text("\(entry.chord.rawValue)\(entry.octave) \(entry.length.rawValue)")
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
                Button(action: createMIDIFile) {
                    Text("Create MIDI File")
                }
                .padding()
                
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
        let newEntry = ChordEntry(chord: selectedChord, octave: selectedOctave, length: selectedLength, strum: strum, durationFactor: durationFactor)
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
            setPath: setInfoModel.setSettings.filesPath
        )
        setInfoModel.setSettings.tracks[trackId]?.chordEntries = chords
        setInfoModel.setSettings.tracks[trackId]?.midiFile = setTrackName
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
    
    private func move(from source: IndexSet, to destination: Int) {
        chords.move(fromOffsets: source, toOffset: destination)
    }
}

//struct MidiView_Previews: PreviewProvider {
//    static var previews: some View {
//        MidiView(chords: <#Binding<[ChordEntry]>#>)
//    }
//}
