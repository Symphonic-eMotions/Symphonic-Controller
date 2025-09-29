//
//  MidiFileModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/05/2024.
//

import AVFoundation
import Foundation

class MidiFileModel {
    private var musicPlayer: MusicPlayer?

    func createMIDIFile(
        chords: [ChordEntry],
        setTrackName: String,
        setPath: String,
        bpm: Double,
        completion: @escaping (Bool) -> Void
    ) {
        var musicSequence: MusicSequence?
        NewMusicSequence(&musicSequence)

        var track: MusicTrack?
        MusicSequenceNewTrack(musicSequence!, &track)

        // Set the BPM
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(musicSequence!, &tempoTrack)
        let tempoEventTime: MusicTimeStamp = 0
        MusicTrackNewExtendedTempoEvent(tempoTrack!, tempoEventTime, bpm)

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

        completion(true) // Indicate that playing has started

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

    func stopPlaying(completion: @escaping (Bool) -> Void) {
        if let musicPlayer = musicPlayer {
            MusicPlayerStop(musicPlayer)
            completion(false) // Indicate that playing has stopped
        }
    }
}
