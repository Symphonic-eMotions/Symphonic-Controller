//
//  SemOne.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 08/07/2023.
//

import AudioKit
import SoundpipeAudioKit

extension Conductor {
    
    internal func SemOne(for track: InstrumentsSet.Track, and sequencer: AppleSequencer) -> Node? {
        let osc = createPWMOscillatorWithPhaseShift(phaseShift: 0.2)
        let stereo = createPanStereoImage(osc1: osc.osc1, osc2: osc.osc2Delay)
        let tb303Filter = RolandTB303Filter(stereo)
        let env = AmplitudeEnvelope(tb303Filter)
        let compressor = Compressor(env)
        createMIDICallbacker(
            sequencer: sequencer,
            osc: osc,
            env: env,
            tb303Filter: tb303Filter,
            track: track
        )
        
        compressor.attackTime = 0.001
        compressor.releaseTime = 0.05
        compressor.threshold = -4
        let volume = soundModuleVolume[track.id] ?? 0
        compressor.$masterGain.value = AUValue(volume)
        
        let chainEffectsNode = chainEffects(for: track, startingNode: compressor)
        let ampEnv = setTrackAmpEnvelope(trackId: track.trackId, startingNode: chainEffectsNode)
        
        mixer.addInput(ampEnv)
            
        return env as Node
    }
    
    func createPWMOscillatorWithPhaseShift(phaseShift: Double) -> (
        osc1: PWMOscillator,
        osc2: PWMOscillator,
        osc2Delay: Delay
    ) {
        let osc1 = PWMOscillator()
        osc1.pulseWidth = 0.5

        let osc2 = PWMOscillator()
        osc2.pulseWidth = 0.5

        // Convert phase shift (in cycles) to time delay (in seconds) at 20Hz
        // 1 cycle at 20Hz = 1/20 seconds, so phaseShift cycles at 20Hz = phaseShift/20 seconds
        let delayTime = phaseShift / 20.0

        // Create a Delay node with osc2 as the input
        let delayOsc2 = Delay(osc2, time: AUValue(delayTime))

        return (osc1, osc2, delayOsc2)
    }
    
    func createPanStereoImage(osc1: PWMOscillator, osc2: Delay) -> Mixer {
        let panner1 = Panner(osc1, pan: -0.6)
        let panner2 = Panner(osc2, pan: 0.6)
        
        let mixer = Mixer()
        mixer.addInput(panner1)
        mixer.addInput(panner2)

        return mixer
    }

    func createPWMOscillator() -> PWMOscillator {
        let osc = PWMOscillator()
        let pulseWidth: AUValue = 0.5
        osc.pulseWidth = pulseWidth
        return osc
    }
    
    func createMIDICallbacker(
            sequencer: AppleSequencer,
            osc: (osc1: PWMOscillator, osc2: PWMOscillator, osc2Delay: Delay),
            env: AmplitudeEnvelope,
            tb303Filter: RolandTB303Filter,
            track: InstrumentsSet.Track) { // -> MIDICallbackInstrument {
            
        var isPlaying: Bool = false
        let callbacker = MIDICallbackInstrument { [self] status, note, velocity in
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            if midiStatus == .noteOn {
                
                //Waarde met aanstuurbare functie vervangen
                let freqRampDuration: AUValue = 0.025
                
                if !isPlaying {
                    osc.osc1.start()
                    osc.osc2.start()
                    //TODO, before switch set, set this to osc.stop()
                    isPlaying = true
                }
                
                var newVelocity = UInt8(max(Double(Int(velocity)) * velocities[track.id]!,0))
                if newVelocity > 127 { newVelocity = 127 }
                osc.osc1.amplitude = AUValue(velocities[track.id]!)
                osc.osc2.amplitude = AUValue(velocities[track.id]!)
                
                //TODO midiStatus == .noteOn does not pass chords, just single notes
                //osc.frequency = note.midiNoteToFrequency()
                
                env.attackDuration = 0.01
                env.decayDuration = 0.05
                env.sustainLevel = 0
                env.releaseDuration = 0.005
                
                let noteOn = MIDIEvent(noteOn: note, velocity: newVelocity, channel: 1)
                env.scheduleMIDIEvent(event: noteOn)
                
                osc.osc1.$frequency.ramp(to: note.midiNoteToFrequency(), duration: freqRampDuration)
                osc.osc2.$frequency.ramp(to: note.midiNoteToFrequency(), duration: freqRampDuration-0.002)
                
                //We control frequency and resonace with 1 parameter, fuck yeah
                let tb303ftlCutOff: Double = 500 - soundModuleParam01[track.id]! * 50
                let resonance = soundModuleParam01[track.id] ?? 0 * 0.8 + 0.5
                
                tb303Filter.$cutoffFrequency.ramp(to: AUValue(tb303ftlCutOff), duration: 0.01)
                tb303Filter.$resonance.ramp(to: AUValue(resonance), duration: 1)
            }
            else if midiStatus == .noteOff {
                
                let noteOff = MIDIEvent(noteOn: note, velocity: 0, channel: 1)
                env.scheduleMIDIEvent(event: noteOff)
            }
        }
        sequencer.setGlobalMIDIOutput(callbacker.midiIn)
//        return callbacker
    }
}
