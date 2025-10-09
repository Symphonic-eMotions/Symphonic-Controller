//
//  ExsSampler.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit
import AVFAudio

extension Conductor {
    func midiSequencerBuffersAndSamplersWithNestedEffects(
        for track: InstrumentsSet.Track,
        length: String,
        currentSetLevel: Double,
        midiChannels: inout [String: Int],
        samplePath: String
    ) -> AppleSequencer? {
        // Use the 1st midi file defined.
        guard let midiFile = track.midiFiles?.first else {
            print("No MIDI file for track id: \(track.id)")
            return nil
        }

        // What is everyting running on?
        let sequencer = AppleSequencer()

        // Try loading MIDI file from the app bundle first
        if let bundleURL = Bundle.main.url(forResource: "Sounds/MIDI/\(midiFile.fileName)", withExtension: "mid") {
            sequencer.loadMIDIFile(fromURL: bundleURL)
        } else {
            // Probeer het te laden vanuit de documentenmap
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let fileURL = documentsDirectory?.appendingPathComponent("\(set.filesPath)/\(midiFile.fileName).\(midiFile.fileExtension)"),
               FileManager.default.fileExists(atPath: fileURL.path) {
                sequencer.loadMIDIFile(fromURL: fileURL)
            } else {
                print("MIDI file \(midiFile.fileName) does not exist at expected location.")
                return nil
            }
        }

        sequencer.setTempo(set.bpm)

        // Default length of 1 loop, for midi memory we need the length of "completeSequenceFromMIDIfile" (the sum of loops)
        var duration = Duration(beats: midiFile.loopLength.first ?? 0)

        // MARK: Actual instruments are loaded in loopSequenceFromMIDIfile

        // Fill sequencer as a copy buffer
        if length == "completeSequenceFromMIDIfile" {
            // Over write loop duration with complete length
            duration = Duration(beats: midiFile.loopLength.reduce(0) { sum, value in sum + value })

            if [.audioBuffer, .audioBufferTimed].contains(track.instrumentType) {
                if let audioFiles = track.audioFiles {
                    var interval: MusicTimeStamp = 0

                    for audioFile in audioFiles {
                        let noteNumber = midiNoteNumberFromFileName(audioFile.fileName) ?? 48

                        let lengthInBeats = lengthInBeatsFromFileName(fileName: audioFile.fileName) ?? audioFile.lengthInBeats

                        // position start with 0 adds PREVIOUS value
                        let startTime = interval
                        // Remember for next loop
                        interval = interval + lengthInBeats

                        print("AudioBufferALL sequencer startTime: \(startTime) audioFileName: \(audioFile.fileName) noteNumber \(noteNumber) and lengthInBeats \(lengthInBeats)")

                        sequencer.tracks.first?.add(
                            noteNumber: MIDINoteNumber(noteNumber),
                            velocity: 127,
                            position: Duration(beats: startTime),
                            duration: Duration(beats: lengthInBeats - 0.0001)
                        )
                    }
                }
            }
        }

        sequencer.setLength(duration)
        sequencer.setLoopInfo(duration, loopCount: 0)
        sequencer.enableLooping()

        // An actual instrument, not a sequencer loaded for copy reference
        if length == "loopSequenceFromMIDIfile" {
            switch track.instrumentType {
            case .oscTrack:
                // Geen AudioKit-onderdelen nodig: deze track wordt via OSC aangestuurd.
                // Eventueel kun je hier logging of initialisatie toevoegen:
                print("OSC track \(track.id) – skipping AudioKit setup")

                // Als je wilt dat deze track later nog toegankelijk is voor OSC-updates:
                trackSequencers[track.id] = nil
                trackSamplers[track.id] = nil
                trackInstruments[track.id] = nil

                // Omdat er geen sequencer of audio nodes zijn, geef gewoon nil terug:
                return nil
                
            case .exsSampler:
                // Create EXS sampler
                trackSamplers[track.id] = createExsSamplerChainEffects(for: track, and: sequencer)

                // Create seperate isVelocity func
                let isVelocitySensitive = isVelocitySensitive(for: track)
                if isVelocitySensitive {
                    // Create MIDI callback instrument
                    // track is used for just the ID
                    trackSequencersCallbackers[track.id] = callBackInstrument(
                        for: track.id,
                        controlling: trackSamplers[track.id]!,
                        on: midiChannels[track.id]!
                    )

                    sequencer.setGlobalMIDIOutput(trackSequencersCallbackers[track.id]!.midiIn)
                } else {
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
            // In all following cases also nested effect chain and track volume envelopes
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

    func createExsSamplerChainEffects(
        for track: InstrumentsSet.Track,
        and _: AppleSequencer
    ) -> MIDISampler? {
        // Gebruik het eerste EXS-bestand dat is gedefinieerd.
        guard let exsFile = track.exsFiles?.first else {
            print("No EXS file for track id: \(track.id)")
            return nil
        }

        let sampler = MIDISampler(name: track.instrumentName)
        sampler.amplitude = track.volume

        // Koppel de sampler aan de audio-engine als deze nog niet is gekoppeld
        if sampler.avAudioNode.engine == nil {
            audioEngine.avEngine.attach(sampler.avAudioNode)
        }

        // Maak de keten van effecten
        let chainEffects: Node = chainEffects(for: track, startingNode: sampler)

        // Koppel chainEffects aan de engine indien nodig
        if chainEffects.avAudioNode.engine == nil {
            audioEngine.avEngine.attach(chainEffects.avAudioNode)
        }

        // Zorg ervoor dat de track mixer is gekoppeld aan de engine
        if let trackMixer = trackMixers[track.id] {
            if trackMixer.avAudioNode.engine == nil {
                audioEngine.avEngine.attach(trackMixer.avAudioNode)
            }

            // Verbind chainEffects met de track mixer
            audioEngine.avEngine.connect(chainEffects.avAudioNode, to: trackMixer.avAudioNode, format: nil)

            // Zorg ervoor dat de hoofdmixer is gekoppeld aan de engine
            if mixer.avAudioNode.engine == nil {
                audioEngine.avEngine.attach(mixer.avAudioNode)
            }

            // Verbind de track mixer met de hoofdmixer
            audioEngine.avEngine.connect(trackMixer.avAudioNode, to: mixer.avAudioNode, format: nil)
        }

        // Start de AudioKit engine als deze nog niet is gestart.
        if !audioEngine.avEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                print("Error starting AudioKit: \(error.localizedDescription)")
            }
        }

        do {
            // Zoek het instrumentbestand in de app-bundle
            if let instrumentURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/\(exsFile.fileName)", withExtension: "exs") {
                // Laad het instrument nadat de sampler aan de engine is toegevoegd en de engine is gestart.
                try sampler.loadInstrument(at: instrumentURL)
            } else {
                print("Instrument file not found: \(exsFile.fileName).exs")
            }
        } catch {
            print("Error loading instrument: \(error.localizedDescription)")
        }

        return sampler
    }
}
