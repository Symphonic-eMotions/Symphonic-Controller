//
//  ExsSampler.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit
import AVFAudio

extension Conductor {
    
    internal func midiSequencerBuffersAndSamplersWithNestedEffects(
        for track: InstrumentsSet.Track,
        length: String,
        currentSetLevel: Double,
        midiChannels: inout [String: Int],
        samplePath: String) -> AppleSequencer? {
            
            // Use the 1st midi file defined.
            guard let midiFile = track.midiFiles?.first else {
                print("No MIDI file for track id: \(track.id)")
                return nil
            }
            
            //What is everyting running on?
            let sequencer = AppleSequencer()
            
            // Try loading MIDI file from the app bundle first
            if let bundlePath = Bundle.main.path(forResource: "Sounds/MIDI/\(midiFile.fileName)", ofType: "mid"),
               FileManager.default.fileExists(atPath: bundlePath) {
                sequencer.loadMIDIFile("Sounds/MIDI/\(midiFile.fileName)")
            }
            
            // If the file does not exist in the app bundle, try loading it from the documents directory
            else {
                
                let documentsDirectory = try? FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false)
                if let documentsDirectory = documentsDirectory {
                    
                    let fileURL = documentsDirectory.appendingPathComponent("\(set.filesPath)/\(midiFile.fileName).\(midiFile.fileExtension)")
                    
                    // Check if file exists at the destination URL
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        sequencer.loadMIDIFile(fromURL: fileURL)
                    } else {
                        print("MIDI file \(midiFile.fileName) does not exist at expected location: \(fileURL.path)")
                        return nil
                    }
                } else {
                    print("Couldn't find the documents directory.")
                    return nil
                }
            }
            
            sequencer.setTempo(set.bpm)
            
            //Default length of 1 loop, for midi memory we need the length of "completeSequenceFromMIDIfile" (the sum of loops)
            var duration = Duration(beats: midiFile.loopLength.first ?? 0)
            
            //MARK: Actual instruments are loaded in loopSequenceFromMIDIfile
            
            //Fill sequencer as a copy buffer
            if length == "completeSequenceFromMIDIfile" {
                
                //Over write loop duration with complete length
                duration = Duration(beats: midiFile.loopLength.reduce(0, {sum, value in sum + value}) )
                
                if [.audioBuffer,.audioBufferTimed].contains(track.instrumentType){
                    
                    if let audioFiles = track.audioFiles {
                        
                        var interval: MusicTimeStamp = 0
                        
                        for audioFile in audioFiles {
                            
                            let noteNumber = midiNoteNumberFromFileName(audioFile.fileName) ?? 48
                            
                            let lengthInBeats = lengthInBeatsFromFileName(fileName: audioFile.fileName) ?? audioFile.lengthInBeats
                            
                            //position start with 0 adds PREVIOUS value
                            let startTime = interval
                            //Remember for next loop
                            interval = interval + lengthInBeats
                            
                            print("AudioBufferALL sequencer startTime: \(startTime) audioFileName: \(audioFile.fileName) noteNumber \(noteNumber) and lengthInBeats \(lengthInBeats)")
                            
                            sequencer.tracks.first?.add(
                                noteNumber: MIDINoteNumber(noteNumber),
                                velocity: 127,
                                position: Duration(beats: startTime),
                                duration: Duration(beats: (lengthInBeats - 0.0001))
                            )
                        }
                    }
                }
            }
            
            sequencer.setLength(duration)
            sequencer.setLoopInfo(duration, loopCount: 0)
            sequencer.enableLooping()
            
            //An actual instrument, not a sequencer loaded for copy reference
            if length == "loopSequenceFromMIDIfile" {
                
                switch track.instrumentType {
                    
                case .exsSampler:
                    
                    //Create EXS sampler
                    trackSamplers[track.id] = createExsSamplerChainEffects(for: track, and: sequencer)
                    
                    //Create seperate isVelocity func
                    let isVelocitySensitive = isVelocitySensitive(for: track)
                    if isVelocitySensitive {
                        
                        //Create MIDI callback instrument
                        //track is used for just the ID
                        trackSequencersCallbackers[track.id] = callBackInstrument(
                            for: track.id,
                            controlling: trackSamplers[track.id]!,
                            on: midiChannels[track.id]!)
                        
                        sequencer.setGlobalMIDIOutput(trackSequencersCallbackers[track.id]!.midiIn)
                    }
                    else{
                        sequencer.setGlobalMIDIOutput(trackSamplers[track.id]!.midiIn)
                    }
                case .audioBuffer:
                    trackSamplers[track.id] = createAudioBufferSamplerChainEffects(
                        for: track,
                        and: sequencer,
                        currentSetLevel: currentSetLevel,
                        samplePath: samplePath
                    )
                case .audioBufferTimed:
                    trackSamplers[track.id] = createAudioBufferTimePitchChainEffects(
                        for: track,
                        and: sequencer,
                        currentSetLevel: currentSetLevel,
                        targetBPM: set.bpm,
                        samplePath: samplePath
                    )
                    //In all following cases also nested effect chain and track volume envelopes
                case .SemOne:
                    trackInstruments[track.id] = SemOne(for: track, and: sequencer)
                case .pulseWidthSynth:
                    trackInstruments[track.id] = createPulseWidthSynth(for: track, and: sequencer)
                case .phaseSynth:
                    trackInstruments[track.id] = createPhaseSynth(for: track, and: sequencer)
                }
            }
            
            return sequencer
        }
    
    internal func createExsSamplerChainEffects(
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
//            let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
            
            //Have an extra mixer to record
            trackMixers[track.id]?.addInput(chainEffects)
            
            //Send the record signal to the main out
            mixer.addInput(trackMixers[track.id]!)
            //mixer.addInput(ampEnv)
            
            do {
                //Recorder
//                let avAudioFile = try AppUtils.createAvAudioFile(set: set, trackName: track.instrumentName)
//                //Use trackMixers to record, you can also hear this signal
//                let recorder = try NodeRecorder(node: trackMixers[track.id]!, file: avAudioFile)
//                trackRecorders[track.id] = recorder
                
                //Load EXS from File
                try sampler.loadEXS24("Sounds/Sampler Instruments/\(exsFile.fileName)")
                
            } catch {
                print("Error loading EXS: \(exsFile.fileName)")
            }
            
            return sampler
        }
    
}
