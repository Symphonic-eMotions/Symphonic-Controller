//
//  MidiFileModel.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/05/2024.
//

import Foundation
import AVFoundation

class MidiFileModel {
    func createMIDIFile(
        chords: [ChordEntry],
        setTrackName: String,
        setPath: String
    ) {
        var musicSequence: MusicSequence?
        NewMusicSequence(&musicSequence)
        
        var track: MusicTrack?
        MusicSequenceNewTrack(musicSequence!, &track)
        
        var timestamp = MusicTimeStamp(0.0)
        
        for entry in chords {
            let baseNotes = entry.chord.notes.map { UInt8($0) }
            let octaveShift = UInt8(entry.octave * 12)
            let notes = baseNotes.map { $0 + octaveShift }
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
        
        var musicPlayer: MusicPlayer?
        NewMusicPlayer(&musicPlayer)
        MusicPlayerSetSequence(musicPlayer!, musicSequence)
        MusicPlayerStart(musicPlayer!)
        
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
}
