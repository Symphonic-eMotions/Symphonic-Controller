//
//  StartTypesMethods.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit

extension Conductor {
    
    //MARK: MidiData
    //TODO: Hier ben ik 13 april 2023
    //Idee maak het wachten op trigger window zichtbaar, balletje dat je wegslaat
    //vertrek snelheid is velocity van triggermoment
    
    private func midiDataNoteOn( noteNumber: Int, velocity: Int, samplerId: String, groupIndex: Int) {
        
        let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(velocity), channel: 1)
        trackSamplers[samplerId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
        
        //Register we are playing
        midiDataGroupNoteNumbers[samplerId]?.append(noteNumber)
        midiDataGroupIndex[samplerId]?.append(groupIndex)
    }
    
    private func midiDataNoteOff( noteNumber: Int, samplerId: String) {
        
        let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
        trackSamplers[samplerId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
        
        //Un register note
        midiDataGroupNoteNumbers[samplerId]?.removeFirst()
        midiDataGroupIndex[samplerId]?.removeFirst()
    }
    
    //Play a note number in a wave
    internal func triggerMidiData(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget ){
            
            //The mimimal amount of movement before looking up a trigger
            guard let minimalLevel = damperTarget.nodeSettings?.minimalLevel else { return }
            
            //Is there a wave present?
            if trackWaveActive[damperTarget.trackId] ?? false {
                
                //End wave, stop note
                //Keeps possibility multiple note ons
                if value < (minimalLevel - (minimalLevel/2)) {
                    
                    //The trigger wave is over
                    trackWaveActive[damperTarget.trackId] = false
                    
                    //First in first out
                    guard let noteNumber = midiDataGroupNoteNumbers[damperTarget.trackId]?.first else { return }
                    midiDataNoteOff(noteNumber: noteNumber, samplerId: damperTarget.trackId)
                }
            }
            //There's no wave present
            else {
                
                //Is there enough movement to start wave?
                if value > minimalLevel {
                    
                    trackWaveActive[damperTarget.trackId] = true
                    
                    let group = damperTarget.midiData!.group
                    
                    //TODO: Creative ways to disclose
                    //Random
                    //let noteNumberIndex = Int.random(in: 0...(group.count-1))
                    //More movement is higher index
                    //
                    
                    let noteNumberIndex = ((midiDataGroupIndex[damperTarget.trackId]?.last)! + 1 ) % group.count
                    let noteNumber = group[noteNumberIndex]
                    let velocity = 127
                    
                    midiDataNoteOn(noteNumber: noteNumber, velocity: velocity, samplerId: damperTarget.trackId, groupIndex: noteNumberIndex)
                }
            }
            //Store value for comparising within this function
            trackWavePreviousValue[damperTarget.trackId] = value
        }
    
//    internal func triggerMidiDataSlaves (
//        value: Double,
//        for damperTarget: InstrumentsSet.Track.Part.DamperTarget ){
//
//            //The mimimal amount of movement before looking up a trigger
//            guard let minimalLevel = damperTarget.nodeSettings?.minimalLevel else { return }
//
//            //Is there a wave present?
//            if trackWaveActive[damperTarget.trackId] ?? false {
//
//                //End wave, stop note
//                //Keeps possabilety multiple note ons
//                if value < (minimalLevel - (minimalLevel/2)) {
//
//                    //The trigger wave is over
//                    trackWaveActive[damperTarget.trackId] = false
//
//                    //Find Self and Slaves. midiData object needs to be in the FIRST instrument part
//                    let startTypes: [StartType] = [.triggerMidiDataSlaves, .midiDataSlave]
//                    set.tracks.filter { startTypes.contains($0.startType) }.forEach {
//                        //First in first out
//                        guard let noteNumber = midiDataGroupNoteNumbers[$0.trackId]?.first else { return }
//                        midiDataNoteOff(noteNumber: noteNumber, samplerId: $0.trackId)
//                    }
//                }
//            }
//            //There's no wave present
//            else {
//
//                //Is there enough movement to start wave?
//                if value > minimalLevel {
//
//                    trackWaveActive[damperTarget.trackId] = true
//
//                    //Find Self and Slaves. midiData object needs to be in the FIRST instrument part
//                    let startTypes: [StartType] = [.triggerMidiDataSlaves, .midiDataSlave]
//                    set.tracks.filter { startTypes.contains($0.startType) }.forEach {
//
//                        let group = $0.parts.first!.damperTarget.midiData!.group
//                        let noteNumberIndex = ((midiDataGroupIndex[$0.trackId]?.last)! + 1 ) % group.count
//                        let noteNumber = group[noteNumberIndex]
//                        let velocity = 127
//
//                        midiDataNoteOn(noteNumber: noteNumber, velocity: velocity, samplerId: $0.trackId, groupIndex: noteNumberIndex)
//                    }
//                }
//            }
//            //Store value for comparising within this function
//            trackWavePreviousValue[damperTarget.trackId] = value
//        }
    
    //Start midiData on transport
    internal func playNoteNumber(_ track: TrackSettings){
            
        //Is current track playing?
        let trackWaveActiveUnwrap = trackWaveActive[track.trackId] ?? false
        
        if !trackWaveActiveUnwrap {
            
            trackWaveActive[track.trackId] = true
            
            let noteNumber = track.midiGroup.first ?? 0
            midiDataGroupNoteNumbers[track.trackId]?.append(noteNumber)
            let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 120, channel: 1)
            trackSamplers[track.trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
        }
    }
    
    internal func stopNoteNumber(_ track: TrackSettings){
            
        //Is current track playing?
        let trackWaveActiveUnwrap = trackWaveActive[track.trackId] ?? false
        
        if trackWaveActiveUnwrap {
            
            trackWaveActive[track.trackId] = false
            
            let noteNumber = track.midiGroup.first ?? 0
            if let index = midiDataGroupNoteNumbers[track.trackId]!.firstIndex(of: noteNumber) {
                midiDataGroupNoteNumbers[track.trackId]?.remove(at: index)
            }
            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
            trackSamplers[track.trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
        }
    }
    

    //MARK: Triggers
    //TODO: Update this with value from global wave
    internal func triggerStartStopGroup(
        value: Double,
        damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        setSettings: SetSettings
    ){
        
        //The mimimal amount of movement before looking up a trigger
        guard let minimalLevel = damperTarget.nodeSettings?.minimalLevel else { return }
        
        //We need the position to hold "fire clip" until next beat
        let currentMoment = trackSequencers["trigger"]?.currentPosition.beats
        
        //scorePartWatingToChange caries the moment the trigger occured
        if scorePartWatingToChange[damperTarget.trackId]! != 0.0 {
           
            //The moment the triggers needs to be minus the current moment
            //If it's not been yet but difference is smaller than 0.05 go trigger by starting wave
            //If the moment is in the past (< currentMoment) also go trigger.
            if scorePartWatingToChange[damperTarget.trackId]! <= currentMoment! {
                
                //Start wave!
                //We need to look up all trigger tracks and start them
                let startTypes: [StartType] = [.loopedTrigger]
                setSettings.tracks.values.filter { startTypes.contains($0.startType) }.forEach {
                    if $0.noteSource == .midiFile { playTrack($0) }
                    if $0.noteSource == .noteNumbers { playNoteNumber($0) }
                }
                
                //Track wave globaly
                trackWaveActive[damperTarget.trackId] = true
                //Reset waiting for fire
                scorePartWatingToChange[damperTarget.trackId]! = 0.0
            }
        }
        //No clip is waiting for triggering
        else{
            
            //Is there a wave present?
            if trackWaveActive[damperTarget.trackId] ?? false {
                
                //Stop wave if current value is lower compared to previous frame minus minimalLevel
                //OR value is below minimal level
                if value < (trackWavePreviousValue[damperTarget.trackId] ?? 0) - minimalLevel
                    || value < minimalLevel {
                    
                    
                    let startTypes: [StartType] = [.loopedTrigger]
                    setSettings.tracks.values.filter { startTypes.contains($0.startType) }.forEach {
                        if $0.noteSource == .midiFile { stopTrack($0) }
                        if $0.noteSource == .noteNumbers { stopNoteNumber($0) }
                    }
                    
                    //The trigger wave is over
                    trackWaveActive[damperTarget.trackId] = false
                }
            }
            //There's no wave present
            else {
                
                //Is there enough movement to start wave?
                if value > minimalLevel {
                    //TODO: nextTriggerMoment - currentMoment! <= 0.001 moet hier uit?
                    //The beat we're in plus one is the next trigger moment
                    let nextTriggerMoment = Double(Int(currentMoment!) + 1)
                    //If the next trigger moment is very close by go ahaed already
                    if nextTriggerMoment - currentMoment! <= 0.001 {
                        //Start wave of slave type tracks
                        let startTypes: [StartType] = [.loopedTrigger]
                        setSettings.tracks.values.filter { startTypes.contains($0.startType) }.forEach {
                            if $0.noteSource == .midiFile { playTrack($0) }
                            if $0.noteSource == .noteNumbers { playNoteNumber($0) }
                        }
                        
                        //Track wave globaly
                        trackWaveActive[damperTarget.trackId] = true
                    }
                    else{
                        //Trigger not yet...
                        scorePartWatingToChange[damperTarget.trackId] = nextTriggerMoment
                    }
                }
            }
            //Store value for comparising within this function
            trackWavePreviousValue[damperTarget.trackId] = value
        }
    }
}
