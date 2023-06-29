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
    
    func midiNoteNumber(fromFileName fileName: String) -> Int? {
        let noteNameToMidi: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5,
            "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11
        ]
        let baseMidiNoteNumberForC0 = 12

        // Split the string into components using "_" as the separator
        let components = fileName.split(separator: "_")
        guard let lastComponent = components.last else { return nil }

        // Split the last component into note and octave
        let noteAndOctave = lastComponent.split(separator: ".").first?.split(separator: "#")
        guard let note = noteAndOctave?.first, let octave = noteAndOctave?.last else { return nil }
        
        guard let noteValue = noteNameToMidi[String(note).uppercased()] else { return nil }
        guard let octaveValue = Int(octave) else { return nil }

        return baseMidiNoteNumberForC0 + (octaveValue * 12) + noteValue
    }
    
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
        
        //This could be used to cennect to editor note numbers, looping can be done
            
        for audioFile in audioFiles {
            
            let noteNumber = midiNoteNumber(fromFileName: audioFile.fileName) ?? 48
            
            sequencer.tracks.first?.add(
                noteNumber: MIDINoteNumber(noteNumber),
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
