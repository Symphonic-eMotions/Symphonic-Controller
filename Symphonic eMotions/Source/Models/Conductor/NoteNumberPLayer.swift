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
    
    //Start midiData on transport
    internal func playNoteNumber(_ track: TrackSettings, _ noteNumber: Int){
            
        let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 120, channel: 1)
        trackSamplers[track.trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
    }
    
    internal func stopNoteNumber(_ track: TrackSettings, _ noteNumber: Int){
        
        let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
        trackSamplers[track.trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
    }
}
