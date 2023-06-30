//
//  createAudioBufferTimePitch.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 09/06/2023.
//

import AudioKit
import SoundpipeAudioKit
import AVFAudio

extension Conductor {
    
    internal func createAudioBufferTimePitch(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer,
        currentSetLevel: Double,
        targetBPM: Double) -> MIDISampler? {
        
        guard let audioFiles = track.audioFiles else {
            print("No audio files for track id: \(track.id)")
            return nil
        }
    
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document directory not found")
            return nil
        }
        
        var avAudioFiles = [AVAudioFile]()
        
        var lengthInBeats: Double = 1
        for audioFile in audioFiles {
            
            let audioFileURL = documentDirectory.appendingPathComponent("Samples/\(audioFile.fileName).\(audioFile.fileExtension)")
            
            if audioFile.lengthInBeats > lengthInBeats {
                lengthInBeats = audioFile.lengthInBeats
            }
            
            do {
                let avAudioFile = try AVAudioFile(forReading: audioFileURL)
                avAudioFiles.append(avAudioFile)
            } catch {
                print("Error loading audio file at \(audioFileURL): \(error)")
            }
        }
            
        sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: lengthInBeats))
            
        for audioFile in audioFiles {
            
            let noteNumber = midiNoteNumberFromFileName(audioFile.fileName) ?? 48
            
            sequencer.tracks.first?.add(
                noteNumber: MIDINoteNumber(noteNumber),
                velocity: 120,
                position: Duration(beats: 0),
                duration: Duration(beats: (audioFile.lengthInBeats - 0.0001))
            )
        }
        
        let sampler = MIDISampler(name: track.instrumentName)
        sampler.amplitude = track.volume
        
        sequencer.setGlobalMIDIOutput(sampler.midiIn)
        
        let timePitch = TimePitch(sampler)
        
        let originalBPM: Double = 128.03 // Provide the original BPM of the sample
        let oneBeatDuration = 60.0 / originalBPM
        let originalDuration = lengthInBeats * oneBeatDuration
        
        let desiredDuration = originalDuration * (targetBPM / originalBPM)
        let desiredNumberOfSamples = desiredDuration * 44100 // Assuming a sample rate of 44.1 kHz
        
        let desiredRate = desiredNumberOfSamples / Double(44100)
        let desiredPitchShift = log2(desiredRate) * 12
        
        timePitch.rate = AUValue(desiredRate)
        timePitch.pitch = AUValue(desiredPitchShift)
        
        let chainEffects: Node = chainEffects(for: track, startingNode: timePitch)
        let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
        
        mixer.addInput(ampEnv)
        
        // This needs to happen last
        do {
            try sampler.loadAudioFiles(avAudioFiles)
        } catch {
            print("Error loading audio files: \(error)")
        }
        
        return sampler
    }
}
