import Foundation
import AVFoundation
import SwiftUI

class MidiFileModel {
    private var musicPlayer: MusicPlayer?
    private var isPlaying = false
    
    func createMIDIFile(
        chords: [ChordEntry],
        setTrackName: String,
        setPath: String
    ) {
        var musicSequence: MusicSequence?
        NewMusicSequence(&musicSequence)
        
        var track: MusicTrack?
        MusicSequenceNewTrack(musicSequence!, &track)
        
        // Set the BPM
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(musicSequence!, &tempoTrack)
        let bpm: Double = 120 // Set this to the desired BPM
        let tempoEventTime: MusicTimeStamp = 0
        let tempoEvent = MusicTrackNewExtendedTempoEvent(tempoTrack!, tempoEventTime, bpm)
        
        var timestamp = MusicTimeStamp(0.0)
        
        for entry in chords {
            let baseNotes = entry.chord.notes.map { UInt8($0) }
            let octaveShift = UInt8(entry.octave * 12)
            var notes = baseNotes.map { $0 + octaveShift }
            
            switch entry.option {
            case .addSecondNoteAsFourth:
                if notes.count > 1 {
                    notes.append(notes[1])
                }
            case .addSeventh:
                if let seventhNote = baseNotes.first.map({ $0 + 10 + octaveShift }) { // Assuming a minor seventh
                    notes.append(seventhNote)
                }
            case .none:
                break
            }
            
            var noteTimestamp = timestamp
            
            for note in notes {
                let noteDuration = entry.length.duration * Float32(entry.durationFactor)
                var noteMessage = MIDINoteMessage(
                    channel: 0,
                    note: note,
                    velocity: 64,
                    releaseVelocity: 0,
                    duration: noteDuration
                )
                MusicTrackNewMIDINoteEvent(track!, noteTimestamp, &noteMessage)
                noteTimestamp += entry.strum // Apply strum
            }
            // Adjust the timestamp based on the length of the note
            timestamp += MusicTimeStamp(entry.length.duration)
        }
        
        NewMusicPlayer(&musicPlayer)
        MusicPlayerSetSequence(musicPlayer!, musicSequence)
        MusicPlayerStart(musicPlayer!)
        isPlaying = true
        
        let fileManager = FileManager.default
        let midiFileName = "\(setTrackName).mid"
        
        // Ensure setPath directory exists
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(setPath, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error.localizedDescription)")
            return
        }
        
        let midiFileURL = directoryURL.appendingPathComponent(midiFileName)
        
        MusicSequenceFileCreate(
            musicSequence!,
            midiFileURL as CFURL,
            .midiType,
            [.eraseFile],
            480 /* resolution */
        )
        
        print("MIDI file created at: \(midiFileURL.path)")
    }
    
    func stopPlaying() {
        if let musicPlayer = musicPlayer {
            MusicPlayerStop(musicPlayer)
            isPlaying = false
        }
    }
    
    func isCurrentlyPlaying() -> Bool {
        return isPlaying
    }
}

struct MidiView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var chords: [ChordEntry]
    var trackId: String
    
    @State private var selectedChord: Chord = .C
    @State private var selectedOctave: Int = 3
    @State private var selectedLength: Length = .whole
    @State private var strum: Double = 0.01
    @State private var durationFactor: Double = 0.95
    @State private var selectedOption: ChordOption = .none
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
                        Text(chord.description).tag(chord)
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
            
            Picker("Chord Option", selection: $selectedOption) {
                Text("None").tag(ChordOption.none)
                Text("Add Second Note as Fourth").tag(ChordOption.addSecondNoteAsFourth)
                Text("Add Seventh").tag(ChordOption.addSeventh)
            }
            .pickerStyle(SegmentedPickerStyle())
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
                if midiFileModel.isCurrentlyPlaying() {
                    Button(action: stopMIDIFile) {
                        Text("Stop MIDI")
                    }
                    .padding()
                }
                
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
            setPath: setInfoModel.setSettings.filesPath
        )
        setInfoModel.setSettings.tracks[trackId]?.chordEntries = chords
        setInfoModel.setSettings.tracks[trackId]?.midiFile = setTrackName
    }
    
    private func stopMIDIFile() {
        midiFileModel.stopPlaying()
    }
    
    private func updateStrumValues(_ newValue: Double) {
        for index in chords.indices {
            chords[index].strum = newValue
        }
    }
    
    private func updateDurationValues(_ newValue: Double) {
