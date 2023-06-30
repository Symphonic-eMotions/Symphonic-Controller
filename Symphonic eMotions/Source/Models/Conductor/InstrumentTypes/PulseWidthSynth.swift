//
//  PulseWidthSynth.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit
import SoundpipeAudioKit

extension Conductor {
    
    internal func createPulseWidthSynth(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer) -> Node? {
        
        var isPlaying: Bool = false
        let osc = PWMOscillator()
        //osc.amplitude = 1
        
        //Waarde vervangen met functie call duratie * sinus voor instant LFO
        //TODO make pulsewidth variable
        let pulseWidth: AUValue = 0.5
        osc.pulseWidth = pulseWidth
        
        //      case .phaseSynth:
        //      osc = PhaseDistortionOscillator()
        //PhaseDistortionOscillator
        
        let tb303ftl = RolandTB303Filter(osc)
        
        let env = AmplitudeEnvelope(tb303ftl)
        
        let compressor = Compressor(env)
            
        //Waarde met aanstuurbare functie vervangen
        let freqRampDuration: AUValue = 0.025
        
        //Sequencer to callback to play sampler
        let callbacker = MIDICallbackInstrument { [self] status, note, velocity in
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            if midiStatus == .noteOn {
                
                if !isPlaying {
                    osc.start()
                    //TODO, before switch set, set this to osc.stop()
                    isPlaying = true
                }
                
                var newVelocity = UInt8(max(Double(Int(velocity)) * velocities[track.id]!,0))
                if newVelocity > 127 { newVelocity = 127 }
                osc.amplitude = AUValue(velocities[track.id]!)
                
                //TODO midiStatus == .noteOn does not pass chords, just single notes
                //osc.frequency = note.midiNoteToFrequency()
                
                env.attackDuration = 0.01
                env.decayDuration = 0.05
                env.sustainLevel = 0
                env.releaseDuration = 0.005
                
                let noteOn = MIDIEvent(noteOn: note, velocity: newVelocity, channel: 1)
                env.scheduleMIDIEvent(event: noteOn)
                
                osc.$frequency.ramp(to: note.midiNoteToFrequency(), duration: freqRampDuration)
                
                let tb303ftlCutOff: Double = 500 - soundModuleParam01[track.id]! * 50
                
                tb303ftl.$cutoffFrequency.ramp(to: AUValue(tb303ftlCutOff), duration: 0.01)
                
                let resonance = soundModuleParam01[track.id] ?? 0 * 0.8 + 0.5
                
                tb303ftl.$resonance.ramp(to: AUValue(resonance), duration: 1)
                
                compressor.attackTime = 0.001
                compressor.releaseTime = 0.05
                compressor.threshold = -4
                let volume = soundModuleVolume[track.id] ?? 0
                
                compressor.$masterGain.value = AUValue(volume)
                
            }
            else if midiStatus == .noteOff {
                
                let noteOff = MIDIEvent(noteOn: note, velocity: 0, channel: 1)
                env.scheduleMIDIEvent(event: noteOff)
            }
        }
        sequencer.setGlobalMIDIOutput(callbacker.midiIn)
        
        
        let chainEffects: Node = chainEffects(for: track, startingNode: compressor)
        let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
        
        mixer.addInput(ampEnv)
        
        return env as Node
    }
}
