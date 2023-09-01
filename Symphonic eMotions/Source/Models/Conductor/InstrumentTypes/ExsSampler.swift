//
//  ExsSampler.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit

extension Conductor {
    
    internal func createExsSampler(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer) -> MIDISampler? {
            
            // Use the 1st exs file defined.
            guard let exsFile = track.exsFiles?.first else {
                print("No EXS file for track id: \(track.id)")
                return nil
            }
            
            let sampler = MIDISampler(name: track.instrumentName)
            sampler.amplitude = track.volume
            
            let chainEffects: Node = chainEffects(for: track, startingNode: sampler)
            let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
            
            //Have an extra mixer to record
            trackMixers[track.id]?.addInput(ampEnv)
            
            //Send the record signal to the main out
            mixer.addInput(trackMixers[track.id]!)
//            mixer.addInput(ampEnv)
            
            do {
                //Recorder
                let avAudioFile = try AppUtils.createAvAudioFile(set: set, trackName: track.instrumentName)
//                Use trackMixers to record, you can also hear this signal
                let recorder = try NodeRecorder(node: trackMixers[track.id]!, file: avAudioFile)
                trackRecorders[track.id] = recorder
                
                //Sampler
                try sampler.loadEXS24("Sounds/Sampler Instruments/\(exsFile.fileName)")
                
            } catch {
                print("Error loading EXS: \(exsFile.fileName)")
            }
            
            return sampler
        }
}
