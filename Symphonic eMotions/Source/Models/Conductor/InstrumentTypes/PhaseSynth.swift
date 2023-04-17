//
//  PhaseSynth.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit
import SoundpipeAudioKit

extension Conductor {
    
    internal func createPhaseSynth(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer) -> Node? {
            
            var isPlaying: Bool = false
            let phaseDistOsc = PhaseDistortionOscillator()
            phaseDistOsc.amplitude = 1.0
            phaseDistOsc.phaseDistortion = -0.85
            
            let pulseWidthOsc = PWMOscillator()
            pulseWidthOsc.amplitude = 1.0
            
            //Waarde vervangen met functie call duratie * sinus voor instant LFO
            let pulseWidth: AUValue = 0.5
            pulseWidthOsc.pulseWidth = pulseWidth
            
            let ampEnvPhaseDist = AmplitudeEnvelope(phaseDistOsc)
            let ampEnvPulseWidth = AmplitudeEnvelope(pulseWidthOsc)
            
            let pitchShiftPhaseDist: Double = -12
            
            //Waarde met aanstuurbare functie vervangen
            let freqRampDurPhaseDist: AUValue = 0.001
            let freqRampDurPulseWidth: AUValue = 0.05
            
            let moogLadder = MoogLadder(ampEnvPulseWidth)
            moogLadder.resonance = 1.5
            moogLadder.cutoffFrequency = 20_000.0
            
            let oscMixer = Mixer()
            
            //Sequencer to callback to play sampler
            let callbacker = MIDICallbackInstrument { [self] status, note, velocity in
                guard let midiStatus = MIDIStatusType.from(byte: status) else {
                    return
                }
                if midiStatus == .noteOn {
                    if !isPlaying {
                        phaseDistOsc.start()
                        pulseWidthOsc.start()
                        //TODO: before switch set, set this to osc.stop()
                        isPlaying = true
                    }
                    
                    //NOTE: midiStatus == .noteOn does not pass chords, just single notes
                    //osc.frequency = note.midiNoteToFrequency()
                    
                    ampEnvPhaseDist.attackDuration = 0.01
                    ampEnvPhaseDist.decayDuration = 0.03
                    ampEnvPhaseDist.sustainLevel = 0.2
                    ampEnvPhaseDist.releaseDuration = 0.2
                    
                    ampEnvPulseWidth.attackDuration = 0.2
                    ampEnvPulseWidth.decayDuration = 0.6
                    ampEnvPulseWidth.sustainLevel = 0.1
                    ampEnvPulseWidth.releaseDuration = 0.2
                    
                    let newNote = UInt8(Double(Int(note)) + pitchShiftPhaseDist)
                    let newVelocity = UInt8(Double(Int(velocity)) * velocities[track.id]!)
                    
                    var noteOn = MIDIEvent(noteOn: newNote, velocity: newVelocity, channel: 1)
                    ampEnvPhaseDist.scheduleMIDIEvent(event: noteOn)
                    
                    noteOn = MIDIEvent(noteOn: newNote, velocity: newVelocity, channel: 1)
                    ampEnvPulseWidth.scheduleMIDIEvent(event: noteOn)
                    
                    phaseDistOsc.$frequency.ramp(to: newNote.midiNoteToFrequency(), duration: freqRampDurPhaseDist)
                    
                    let phaseDistortion: Double = soundModuleParam01[track.id]! * -2.0 + 1.0
                    phaseDistOsc.$phaseDistortion.ramp(to: AUValue(phaseDistortion), duration: 2.0)
                    
                    let moogCutOffFrequencey: Double = soundModuleParam01[track.id]! * 2000
                    moogLadder.$cutoffFrequency.ramp(to: AUValue(moogCutOffFrequencey), duration: 3.0)
                    
                    let microTune: AUValue = newNote.midiNoteToFrequency() + 0.1
                    pulseWidthOsc.$frequency.ramp(to: microTune, duration: freqRampDurPulseWidth)
                    
                    
                }
                else if midiStatus == .noteOff {
                    
                    var newNote = UInt8(Double(Int(note)) + pitchShiftPhaseDist)
                    var noteOff = MIDIEvent(noteOn: newNote, velocity: 0, channel: 1)
                    ampEnvPhaseDist.scheduleMIDIEvent(event: noteOff)
                    
                    newNote = UInt8(Double(Int(note)) + (pitchShiftPhaseDist * 2))
                    noteOff = MIDIEvent(noteOn: newNote, velocity: 0, channel: 1)
                    ampEnvPulseWidth.scheduleMIDIEvent(event: noteOff)
                    
                    //TODO add trackNotesOn tracker
                }
            }
            sequencer.setGlobalMIDIOutput(callbacker.midiIn)
            
            oscMixer.addInput(ampEnvPhaseDist)
            oscMixer.addInput(moogLadder)
            
            let chainEffects: Node = chainEffects(for: track, startingNode: ampEnvPhaseDist)
            let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
            
            mixer.addInput(ampEnv)
            
            return ampEnvPhaseDist as Node
        }
}
