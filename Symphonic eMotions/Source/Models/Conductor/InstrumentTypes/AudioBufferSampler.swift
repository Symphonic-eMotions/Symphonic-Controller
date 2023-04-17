//
//  AudioBufferSampler.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit
import SoundpipeAudioKit
import AVFAudio

extension Conductor {
    
    internal func createAudioBufferSampler(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer,
        currentSetLevel: Double) -> MIDISampler? {
        
        // Use the 1st audio file defined.
        guard let audioFile = track.audioFiles?.first else { // TODO: Why is this an array?!?
            print("No audio file for track id: \(track.id)")
            return nil
        }
        
        // Use the 1st audio file defined.
        guard let midiFile = track.midiFiles?.first else { // TODO: Why is this an array?!?
            print("No midi file for track id: \(track.id)")
            return nil
        }
        
        
        guard let audioFileURL = Bundle.main.url(forResource: audioFile.fileName, withExtension: audioFile.fileExtension, subdirectory: "Samples/") else {
            print("Audio file not found at path Samples/\(audioFile.fileName).\(audioFile.fileExtension) for track id: \(track.id)")
            return nil
        }
        var avAudioFiles = [AVAudioFile]()
        
        let sampler = MIDISampler(name: track.instrumentName)
        sampler.amplitude = track.volume
        
        let loopLength = midiFile.loopLength.first
        sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: loopLength ?? 64))
        
        //tempoTrack is optional instrument track without sound (grey instrument)
        //MARK: Tempo Track
        if track.id == "tempoTrack"  {
            
            let velocitySLider = 0
            
            for i in 0..<Int(loopLength ?? 4) {
                
                var velocity = 80 * velocitySLider
                if i == 0 { velocity = 120 * velocitySLider}
                
                sequencer.tracks.first?.add(
                    noteNumber: audioFile.midiNote,
                    velocity: MIDIVelocity(velocity),
                    position: Duration(beats: Double(i)),
                    duration: Duration(beats: 0.05)
                )
                
                sequencer.tracks.first?.add(
                    noteNumber: audioFile.midiNote,
                    velocity: MIDIVelocity(40 * velocitySLider),
                    position: Duration(beats: (Double(i) + 0.25)),
                    duration: Duration(beats: 0.05)
                )
                
                sequencer.tracks.first?.add(
                    noteNumber: audioFile.midiNote,
                    velocity: MIDIVelocity(60 * velocitySLider),
                    position: Duration(beats: (Double(i) + 0.5)),
                    duration: Duration(beats: 0.05)
                )
                
                sequencer.tracks.first?.add(
                    noteNumber: audioFile.midiNote,
                    velocity: MIDIVelocity(40 * velocitySLider),
                    position: Duration(beats: (Double(i) + 0.75)),
                    duration: Duration(beats: 0.05)
                )
            }
            
            let callbacker = MIDICallbackInstrument { status, note, velocity in
                
                guard let midiStatus = MIDIStatusType.from(byte: status) else {
                    return
                }
                
                if midiStatus == .noteOn {
                    sampler.play(noteNumber: note, velocity: velocity, channel: 1)
                }
                else if midiStatus == .noteOff {
                    sampler.stop(noteNumber: note, channel: 1)
                }
            }
            sequencer.setGlobalMIDIOutput(callbacker.midiIn)
        }
        
        else{
            sequencer.tracks.first?.add(
                noteNumber: audioFile.midiNote,
                velocity: 120,
                position: Duration(beats: 0),
                duration: Duration(beats: midiFile.loopLength.first ?? 4)
            )
            
            sequencer.setGlobalMIDIOutput(sampler.midiIn)
        }
        
        let chainEffects: Node = chainEffects(for: track, startingNode: sampler)
        let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
        
        mixer.addInput(ampEnv)
        
        do {
            //            try sampler.loadAudioFile(try AVAudioFile(forReading: audioFileURL))
            try avAudioFiles.append(AVAudioFile(forReading: audioFileURL))
            try sampler.loadAudioFiles(avAudioFiles)
            
        } catch {
            print("Error audioFileURL: \(audioFileURL)")
        }
        
        return sampler
    }
}
