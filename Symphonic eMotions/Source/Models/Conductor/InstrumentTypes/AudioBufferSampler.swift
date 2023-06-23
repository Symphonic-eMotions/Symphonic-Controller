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
        currentSetLevel: Double,
        samplePath: String) -> MIDISampler? {
        
        //Get audioFiles config
        guard let audioFiles = track.audioFiles else {
            print("No audio files for track id: \(track.id)")
            return nil
        }
    
        //Get ready for user files
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document directory not found")
            return nil
        }
        
        //Store files in RAM
        var avAudioFiles = [AVAudioFile]()
        
        //TODO: Solve for looping stems
        //Create midiSequence in real time based on given midinumber
        var lengthInBeats: Double = 1
            
        for audioFile in audioFiles {
            
            var audioFileURL = URL("noPath")
            
            //Load System file
            if audioFile.source == .bundle {
                audioFileURL = Bundle.main.url(
                    forResource: audioFile.fileName,
                    withExtension: audioFile.fileExtension,
                    subdirectory: "Samples/\(samplePath)"
                ) ?? URL("errorFileName")
                
            } else {
                //Load User file
                audioFileURL = documentDirectory.appendingPathComponent(
                    "\(samplePath)/\(audioFile.fileName).\(audioFile.fileExtension)"
                )
            }
            
            //Get the longest length in beat
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
            sequencer.tracks.first?.add(
                noteNumber: audioFile.midiNote,
                velocity: 127,
                position: Duration(beats: 0),
                duration: Duration(beats: (audioFile.lengthInBeats - 0.0001))
            )
        }
        
        let sampler = MIDISampler(name: track.instrumentName)
        sampler.amplitude = track.volume
            
        sequencer.setGlobalMIDIOutput(sampler.midiIn)
    
        let chainEffects: Node = chainEffects(for: track, startingNode: sampler)
        let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
        
        mixer.addInput(ampEnv)
        
        //This needs to happen as last
        do {
            try sampler.loadAudioFiles(avAudioFiles)

        } catch {
            print("Error avAudioFiles: \(avAudioFiles)")
        }
        
        return sampler
    }
}
