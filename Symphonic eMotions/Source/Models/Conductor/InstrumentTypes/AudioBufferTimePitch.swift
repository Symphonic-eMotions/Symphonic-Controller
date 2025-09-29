//
//  AudioBufferTimePitch.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 09/06/2023.
//

import AudioKit
import AVFAudio
import SoundpipeAudioKit

extension Conductor {
    func createAudioBufferTimePitchChainEffects(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer,
        currentSetLevel _: Double,
        targetBPM: Double,
        samplePath: String
    ) -> MIDISampler? {
        // Get audioFiles config
        guard let audioFiles = track.audioFiles else {
            print("No audio files for track id: \(track.id)")
            return nil
        }

        // Get ready for user files
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document directory not found")
            return nil
        }

        // Store files in RAM
        var avAudioFiles = [AVAudioFile]()

        // TODO: Solve for looping stems
        // Create midiSequence in real time based on given midinumber
        var longestLengthInBeats: Double = 1

        for audioFile in audioFiles {
            var audioFileURL = URL("noPath")

            // Load System file
            if audioFile.source == .bundle {
                audioFileURL = Bundle.main.url(
                    forResource: audioFile.fileName,
                    withExtension: audioFile.fileExtension,
                    subdirectory: "Samples/\(samplePath)"
                ) ?? URL("errorFileName")

            } else {
                // Load User file
                audioFileURL = documentDirectory.appendingPathComponent(
                    "\(samplePath)/\(audioFile.fileName).\(audioFile.fileExtension)"
                )
            }

            // clearRange
            if audioFile.lengthInBeats > longestLengthInBeats {
                longestLengthInBeats = audioFile.lengthInBeats
            }

            do {
                let avAudioFile = try AVAudioFile(forReading: audioFileURL)
                avAudioFiles.append(avAudioFile)
            } catch {
                print("Error loading audio file at \(audioFileURL): \(error)")
            }
        }

        // Clear range is the reason there are 2 audioFile loops
        sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: longestLengthInBeats))

        // Fill sequencer with midi info from file name and setting
        var interval: MusicTimeStamp = 0

        for audioFile in audioFiles {
            let noteNumber = midiNoteNumberFromFileName(audioFile.fileName) ?? 48
            let lengthInBeats = lengthInBeatsFromFileName(fileName: audioFile.fileName) ?? audioFile.lengthInBeats

            // position start with 0 adds PREVIOUS value
            let startTime = interval
            // Remember for next loop
            interval = interval + lengthInBeats

//                print("AudioBuffer sequencer startTime: \(startTime) noteNumber \(noteNumber) and lengthInBeats \(lengthInBeats)")
//
            sequencer.tracks.first?.add(
                noteNumber: MIDINoteNumber(noteNumber),
                velocity: 127,
                position: Duration(beats: startTime),
                duration: Duration(beats: lengthInBeats - 0.0001)
            )
        }
        let sampler = MIDISampler(name: track.instrumentName)
        sampler.amplitude = track.volume

        sequencer.setGlobalMIDIOutput(sampler.midiIn)

        let timePitch = TimePitch(sampler)

        let originalBPM = 128.03 // Provide the original BPM of the sample
        let oneBeatDuration = 60.0 / originalBPM
        let originalDuration = longestLengthInBeats * oneBeatDuration

        let desiredDuration = originalDuration * (targetBPM / originalBPM)
        let desiredNumberOfSamples = desiredDuration * 44100 // Assuming a sample rate of 44.1 kHz

        let desiredRate = desiredNumberOfSamples / Double(44100)
        let desiredPitchShift = log2(desiredRate) * 12

        timePitch.rate = AUValue(desiredRate)
        timePitch.pitch = AUValue(desiredPitchShift)

        let chainEffects: Node = chainEffects(for: track, startingNode: timePitch)
//        let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)

        mixer.addInput(chainEffects)

        // This needs to happen last
        do {
            try sampler.loadAudioFiles(avAudioFiles)
        } catch {
            print("Error loading audio files: \(error)")
        }

        return sampler
    }
}
