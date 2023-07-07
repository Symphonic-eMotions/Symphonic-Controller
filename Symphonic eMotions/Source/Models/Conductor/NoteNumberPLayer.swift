//
//  NoteNumberPLayer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit

extension Conductor {
    
    //MARK: Play midi files and note numbers
    internal func playTrack(_ track: TrackSettings) {
        trackSequencers[track.trackId]?.play()
    }
    
    // Stop a track
    internal func stopTrack(_ track: TrackSettings) {
        trackSequencers[track.trackId]?.stop()
        trackSequencers[track.trackId]?.rewind()
        trackSequencers[track.trackId]?.preroll()
    }
    
    internal func playNoteNumber(_ track: TrackSettings, _ noteNumber: Int){
            
        let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 120, channel: 1)
        trackSamplers[track.trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
    }
    
    internal func stopNoteNumber(_ track: TrackSettings, _ noteNumber: Int) {
        if let sampler = trackSamplers[track.trackId] {
            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
            sampler.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
        } else {
            // Handle the case when track.trackId is not found in trackSamplers
            print("Track ID: \(track.trackId) not found in trackSamplers")
        }
    }
    
    //We also need to start the sequncer on transport start
    
    internal func playNoteNumberLength(_ track: TrackSettings, _ noteNumber: Int, _ value: Double){
        
        //Check if current note is done playing, if not return
        let currentPosition = trackSequencers[track.trackId]?.currentPosition
        if let trackNotes = endTimesNotes[track.trackId], trackNotes.keys.contains(noteNumber) {
            if trackNotes[noteNumber]! > currentPosition! {
                return
            }
        }
                
        // Schedule the note-on event
        let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 120, channel: 1)
        trackSamplers[track.trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
        
        // Calculate the offset for the note-off event based on value, adjust the multiplier as needed.
        // This example assumes your audio engine's sample rate is 44.1kHz, and value ranges from 0.1 to 1
        // Adjust the sample rate and the multiplier as needed to fit your app's settings
        let sampleRate: Double = Settings.sampleRate
        //This is how long the note on will persist, this time a new note is not possible
        let noteLength: Double = (value * 3)
        let offset: UInt64 = UInt64(noteLength * sampleRate)
        
        // Convert the offset to Duration and store for comparison
        let offsetDuration = Duration(beats: noteLength * sampleRate / sampleRate)
        endTimesNotes[track.trackId]![noteNumber] = offsetDuration + currentPosition!

        // Schedule the note-off event
        let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
        trackSamplers[track.trackId]!.scheduleMIDIEvent(event: noteOff, offset: offset)

    }
}
