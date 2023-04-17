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
            guard let exsFile = track.exsFiles?.first else { // TODO: Why is this an array?!?
                print("No EXS file for track id: \(track.id)")
                return nil
            }
            
            let sampler = MIDISampler(name: track.instrumentName)
            sampler.amplitude = track.volume
            
            let chainEffects: Node = chainEffects(for: track, startingNode: sampler)
            let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
            
            mixer.addInput(ampEnv)
            
            do {
                
                try sampler.loadEXS24("Sounds/Sampler Instruments/\(exsFile.fileName)")
            } catch {
                print("Error loading EXS: \(exsFile.fileName)")
            }
            
            return sampler
        }
}
