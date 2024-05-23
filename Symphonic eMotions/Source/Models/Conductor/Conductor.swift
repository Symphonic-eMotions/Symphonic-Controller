//
//  Conductor.swift
//  eMotion
//
//  Created by Mihai Fratu on 30.09.2021.
//

import AudioKit
import SoundpipeAudioKit
import AVFAudio
import Accelerate
import Combine
import Dispatch
import SwiftUI

final class Conductor {
    
    var userSettings: UserSettings
    
    let autoVoice = AVSpeechSynthesizer()
    var autoSound: AVAudioPlayer!
    
    //MARK: Var declarations
    //Audiokit AudioEngine. One engine is running at all times
    //Gets pauzed on set change
    internal var audioEngine: AudioEngine
    //First mixer mixes the output of the effect chains per instrument
    internal var mixer: Mixer
    //Second mixer is the output of the first mixer's effect chain output
    private var mixerMaster: Mixer
    
    //trackMaxers for recording tracks
    internal var trackMixers: [String: Mixer] = [:]
    internal var trackRecorders: [String: NodeRecorder] = [:]
    
    //Amplitude controller with interpolation per track
    internal var amplitudeControllers: [String: AmplitudeController] = [:]
    
    //trackSequencers holds MIDI file information
    //Is the play head in the score
    //Controls speed, loop (length)
    //The playhead only moves lineair
    internal var trackSequencers: [String: AppleSequencer] = [:]
    //To move the playhead to another part in the score:
    //Copy part to move to current length playing
    internal var trackSequencersMemory: [String: AppleSequencer] = [:]
    //Modifying midi like velocity
    internal var trackSequencersCallbackers: [String: MIDICallbackInstrument] = [:]
    //Velocities per track to be controlled by intrumentParts
    internal var velocities: [String: Double] = [:]
    //Modify tempo while playing
    private var currentTempo: Double = 0
    
    
    //MARK: InstrumentTypes
    internal var soundModuleParam01: [String: Double] = [:]
    internal var soundModuleParam02: [String: Double] = [:]
    internal var soundModuleVolume: [String: Double] = [:]
    
    //MARK: Time based envelopes
    // Dictionary om TimeBasedEnvelope instanties per partNr te beheren
    internal var timeBasedEnvelopes: [String: TimeBasedEnvelope] = [:]
    
    //MARK: Ramp values containers stored per Instrument.Part
    public var rampValues: [String: Double] = [:]
    //Ramp up and Ramp down values from struct and control from editor
    public var rampUp: [String: Double] = [:]
    public var rampDown: [String: Double] = [:]
    //Volume also controlled by editor
    public var volume: [String: Double] = [:]
    
    //EXS Sampler AND Buffer sampler container
    internal var trackSamplers: [String: MIDISampler] = [:]
    //Synth container
    internal var trackInstruments: [String: Node] = [:]
    
    //Buffer sampler voor samples met adsr
    internal var effectSamplers: [UUID: MIDISampler]?
    internal var effectTypeToUUIDs: [EffectType: [UUID]] = [:]
    internal var rewindIsPlaying: UUID? = nil
//    internal var effectAmpEnvs: [UUID: AmplitudeEnvelope]?
    
    
    //Amplitude enelopes for muting tracks for levels
    //TODO: init of these needs to be at 0 (-90Db)
//    private var trackAmpEnvelopes: [String: AmplitudeEnvelope] = [:]
    
    //Intermediair for sending data back to interface, visual feedback
    var forwardRampedPartFeedback = CurrentValueSubject<Double, Never>(0)
    
    //The main instrument set structure. A Musical set is loaded into this struct
    internal var set: InstrumentsSet
    
    //Play diffrent samples in introduction volume control:
    var lastNoteNumber: Int?
    
    //Debug var
    internal var lastRounded: [String: Double] = [:]
    
    //MARK: Init
    init(
        userSettings: UserSettings = UserSettings.shared,
        set: InstrumentsSet
    ) {
        self.userSettings = userSettings
        self.set = set
        
        let silentUtterance = AVSpeechUtterance(string: "")
        autoVoice.speak(silentUtterance)
        
        audioEngine = AudioEngine()
        mixer = Mixer()
        mixerMaster = Mixer()
        loadMaster(mixer: mixer)
        audioEngine.output = mixerMaster
        loadTracks(currentSetLevel: 0)
    }
    
    //Function to reset variables, is called on change of set
    public func setInitialState() {
        velocities = [:]
        soundModuleParam01 = [:]
        soundModuleParam02 = [:]
        soundModuleVolume = [:]
//        trackAmpEnvelopes = [:]
        rampUp = [:]
        rampDown = [:]
        volume = [:]
        trackSamplers = [:]
        trackMixers = [:]
        trackRecorders = [:]
        trackSequencersCallbackers = [:]
        trackSequencers = [:]
        trackSequencersMemory = [:]
        trackInstruments = [:]
        timeBasedEnvelopes = [:]
        amplitudeControllers = [:]
        
        effectSamplers = [:]
        effectTypeToUUIDs = [:]
        rewindIsPlaying = nil
//        effectAmpEnvs = [:]
        
        //Debug var
        lastRounded = [:]
    }
    
    //Function which is called when switching between sets
    public func currentConductorInstrumentsSetChanged(
        newInstrumentsSet: InstrumentsSet,
        currentSetLevel: Double,
        setSettings: SetSettings
    ) {
        /*
         
         First clear all current settings by resetting all containers
         Then load all tracks and master
         
         */
        
        currentTempo = newInstrumentsSet.bpm
        
        set.tracks.forEach { track in
            
            //Replace all EXS files with the empty trigger.exs to prefent too many files open
            //Remove exs from memory
            if trackSamplers[track.id] != nil {
                
                if let notesArePlaying = setSettings.tracks[track.id]?.notesArePlaying {
                    
                    for maxIndex in notesArePlaying {
                        
                        if let noteNumber = setSettings.tracks[track.id]?.notesToGrid[maxIndex] {
                            
                            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
                            trackSamplers[track.id]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
                        }
                    }
                }
                do {
                    //Close file by loading empty exs
                    try trackSamplers[track.id]!.loadEXS24("Sounds/Sampler Instruments/trigger")
                } catch {
                    print("Error loading EXS: trigger")
                }
                
                trackSamplers[track.id]!.destroyEndpoint()
                trackSamplers.removeValue(forKey: track.id)
                trackSamplers[track.id] = nil
            }
            
            if( trackMixers[track.id] != nil ) {
                trackMixers[track.id]?.removeAllInputs()
                trackMixers[track.id] = nil
            }
            
            if( trackRecorders[track.id] != nil ){
                trackRecorders[track.id] = nil
            }
            
            if( trackInstruments[track.id] != nil ) {
                trackInstruments.removeValue(forKey: track.id)
                trackInstruments[track.id] = nil
            }
            
            if( trackSequencers[track.id] != nil ) {
                trackSequencers.removeValue(forKey: track.id)
                trackSequencers[track.id] = nil
            }
            
            if( trackSequencersMemory[track.id] != nil ) {
                trackSequencersMemory.removeValue(forKey: track.id)
                trackSequencersMemory[track.id] = nil
            }
            
            if( trackSequencersCallbackers[track.id] != nil ) {
                trackSequencersCallbackers.removeValue(forKey: track.id)
                trackSequencersCallbackers[track.id] = nil
            }
            
//            if( trackAmpEnvelopes[track.id] != nil ) {
//                trackAmpEnvelopes.removeValue(forKey: track.id)
//                trackAmpEnvelopes[track.id] = nil
//            }
        }
        
        if let effectSetsDict = effectSamplers {
            for (_, sampler) in effectSetsDict {
                
                // Loop through all MIDI note numbers from 0 to 127
                for noteNumber in 0...127 {
                    let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
                    // Schedule the noteOff event here
                    sampler.scheduleMIDIEvent(event: noteOff)
                }
                
                // Attempt to load the empty EXS file to free up resources
                do {
                    try sampler.loadEXS24("Sounds/Sampler Instruments/trigger")
                } catch {
                    print("Error loading EXS: trigger")
                }
                
                // Cleanup and release resources
                sampler.destroyEndpoint()
            }
//            if( trackAmpEnvelopes[track.id] != nil ) {
//                trackAmpEnvelopes.removeValue(forKey: track.id)
//                trackAmpEnvelopes[track.id] = nil
//            }
            effectSamplers = [:]
            effectTypeToUUIDs = [:]
            rewindIsPlaying = nil
//            effectAmpEnvs = [:]
        }
        
        mixer.removeAllInputs()
        mixerMaster.removeAllInputs()
        
        setInitialState()
        set = newInstrumentsSet
        
        print("Loading: \(set.name) : \(set.customName)")
        
        loadTracks(currentSetLevel: currentSetLevel)
        effectSamplers = loadEffectSamplers()
        loadMaster(mixer: mixer)
    }
    
    
    //Load Master Track settings
    //MARK: Load Master Track
    private func loadMaster(mixer: Node) {
        
        mixerMaster.addInput(chainMasterEffects(for: set.masterTrackEffects, startingNode: mixer))
    }
    
    //Load tracks in audio engine
    // MARK: Load tracks
    private func loadTracks(currentSetLevel: Double ){
        
        //Create tupple with midichannel per midi only instrument (Deprecate?)
        var midiChannels = collectMidiChannels()
        
        set.tracks.forEach { track in
            
            trackMixers[track.id] = Mixer()
            
            //SoundModule controlled velocity
            //Initialize velocity to zero for silent start of these instrument
            var startVelocity = 0.0
            //Initialize levelparts
            //Create ramp
            if track.parts.count > 0 {
                track.parts.forEach { part in
                    if part.damperTarget.parameter == "velocity" {
                        startVelocity = 0.0
                    }
                    else {
                        startVelocity = 1.0
                    }
                    rampValues[part.id] = 0.0
                    rampUp[part.id] = part.damperTarget.nodeSettings!.rampSpeed ?? -1
                    rampDown[part.id] = part.damperTarget.nodeSettings!.rampSpeedDown ?? -1
                    
                    timeBasedEnvelopes[part.id] = TimeBasedEnvelope()
                }
            }
            velocities[track.id] = startVelocity
            
            //Load sequencers
            //Within this function the EXS is also loaded
            trackSequencersCallbackers[track.id] = nil
            trackSequencers[track.id] = midiSequencerBuffersAndSamplersWithNestedEffects(
                for: track,
                length: "loopSequenceFromMIDIfile",
                currentSetLevel: currentSetLevel,
                midiChannels: &midiChannels,
                samplePath: set.filesPath
            )
            
            //Make dummy connectors for memory sequences to silence them in triggers module
            var midiChannelsDummy: [String: Int] = [:]
            trackSequencersMemory[track.id] = midiSequencerBuffersAndSamplersWithNestedEffects(
                for: track,
                length: "completeSequenceFromMIDIfile",
                currentSetLevel: currentSetLevel,
                midiChannels: &midiChannelsDummy,
                samplePath: set.filesPath
            )
            
            soundModuleParam01[track.id] = 0
            soundModuleParam02[track.id] = 0
            soundModuleVolume[track.id] = 0
            
            //In level after level open trackAmpEnvelope 1 level early
            //OR replace with amplitudeControllers
            amplitudeControllers[track.id] = AmplitudeController()
            
            
//            //Turn tracks off so things will be quiet to start off with
//            if let trackAmpEnvelope = trackAmpEnvelopes[track.id] {
//                let envOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
//                trackAmpEnvelope.scheduleMIDIEvent(event: envOff)
//            } else {
//                print("trackAmpEnvelopes[track.id] is nil")
//            }
        }
    }
    
    private func loadEffectSamplers() -> [UUID : MIDISampler]? {
            
        //Get file info from config
        guard let setEffects = set.setEffects else {
            print("No set effects for this set available")
            return nil
        }
        
        //Get ready for user files
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document directory not found")
            return nil
        }
        
        var setEffectSamplers = [UUID: MIDISampler]()
        
        for setEffect in setEffects {
            
            //Remember uuid for playing samplers
            addSetEffect(setEffect)
            
            //Store files in RAM
            var avAudioFiles = [AVAudioFile]()

            var audioFileURL = URL("noPath")
            
            var sampleFolder: String = set.filesPath;
            if setEffect.effectType == .rewind {
                sampleFolder = "Rewind";
            }
//            else if setEffect.effectType == .applause {
//                sampleFolder = "Applause"
//            }
            
            for audioFile in setEffect.audioFiles {
                if setEffect.fileSource == .bundle {
                    audioFileURL = Bundle.main.url(
                        forResource: audioFile.fileName,
                        withExtension: audioFile.fileExtension,
                        subdirectory: sampleFolder
                    ) ?? URL("Samples/\(sampleFolder)/\(audioFile.fileName).\(audioFile.fileExtension)")
                    
                    print("Loading bundle \(audioFileURL)")
                    
                } else {
                    //Load User file
                    audioFileURL = documentDirectory.appendingPathComponent(
                        "\(sampleFolder)/\(audioFile.fileName).\(audioFile.fileExtension)"
                    )
                    
                    print("Loading user file \(audioFileURL)")
                }
            }
            
            do {
                let avAudioFile = try AVAudioFile(forReading: audioFileURL)
                avAudioFiles.append(avAudioFile)
            } catch {
                print("Error loading audio file at \(audioFileURL): \(error)")
            }
            
            let sampler = MIDISampler(name: "Effect Sampler")
            sampler.amplitude = 5
            
            setEffectSamplers[setEffect.id] = sampler
            
//            let envelope = AmplitudeEnvelope(sampler)
//            envelope.attackDuration = AUValue(setEffect.adsrEnvelope.attack)
//            envelope.decayDuration = AUValue(setEffect.adsrEnvelope.decay)
//            envelope.sustainLevel = AUValue(setEffect.adsrEnvelope.sustain)
//            envelope.releaseDuration = AUValue(setEffect.adsrEnvelope.release)
//            
//            effectAmpEnvs?[setEffect.id] = envelope
            
            mixerMaster.addInput(sampler)
            
            //This needs to happen as last
            do {
                try sampler.loadAudioFiles(avAudioFiles)

            } catch {
                print("Error loadEffectSampler avAudioFiles: \(avAudioFiles)")
            }
        }
        return setEffectSamplers
    }
    
    func addSetEffect(_ setEffect: InstrumentsSet.SetEffect) {
        let effectType = setEffect.effectType
        let uuid = setEffect.id
        
        // Add or create uuid array per affectType
        if var uuids = effectTypeToUUIDs[effectType] {
            uuids.append(uuid)
            effectTypeToUUIDs[effectType] = uuids
        } else {
            effectTypeToUUIDs[effectType] = [uuid]
        }
    }
    
    func envelopeSamplerPlay(effectType: EffectType, identifier: Int) -> UUID? {
        guard let uuid = uuid(for: effectType, identifier: identifier),
              let sampler = effectSamplers?[uuid] else {
            return nil
        }

//        effectAmpEnvs?[uuid]?.start()

        let noteNumber = 60
        let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(127), channel: 1)
        sampler.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))

        return uuid
    }
    
    func envelopeSamplerStop(uuid: UUID) {
        guard let sampler = effectSamplers?[uuid] else {
            return
        }

//        effectAmpEnvs?[uuid]?.stop()

        let noteNumber = 60
        let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
        sampler.scheduleMIDIEvent(event: noteOff)
    }
    
    func uuid(for effectType: EffectType, identifier: Int) -> UUID? {
        guard let uuids = effectTypeToUUIDs[effectType], !uuids.isEmpty else {
            return nil
        }
        //return an uuid connected to level if possible
        let index = (identifier - 1) % uuids.count
        return uuids[index]
    }

    
    //MARK: EDITOR
    public func previewSingleTrack(
        trackId: String,
        soundSource: InstrumentsSet.Track.InstrumentType
    ){
        
        if trackSequencers[trackId] != nil {
            
            let isPLaying = trackSequencers[trackId]!.isPlaying
            
            if isPLaying {
                
                if [.exsSampler,.audioBuffer,.audioBufferTimed].contains(soundSource){
                    for note in 0...127 {
                        trackSamplers[trackId]!.stop(noteNumber: MIDINoteNumber(note), channel: 1)
                    }
                }
                trackSequencers[trackId]?.stop()
                trackSequencers[trackId]?.rewind()
                trackSequencers[trackId]?.preroll()
                
            }
            else{
                playEngineUIEffect()
                
//                let envOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
//                trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: envOn)
                
                velocities[trackId] = 1.0
                
                print("play previewSingleTrack \(trackId)")
                
                trackSequencers[trackId]?.play()
            }
        }
        else{
            print("no trackSequencers found")
        }
    }
    
    public func loopSingleTrack(
        trackId:String,
        loopLength:Double,
        isLooping:Bool
    ){
        if trackSequencers[trackId] != nil {
            
            if isLooping {
                trackSequencers[trackId]?.disableLooping()
            }
            else{
                trackSequencers[trackId]?.enableLooping(Duration(beats: loopLength))
                trackSequencers[trackId]?.setLength(Duration(beats: loopLength))
                trackSequencers[trackId]?.setLoopInfo(Duration(beats: loopLength), loopCount: 0)
                
            }
        }
    }
    
    public func copyMidiSingleTrack(trackId:String,nextVariation:Int,loopLength:[Double]){
        
        let nextMIDIstartTime = calculateMIDIstartTime(for: nextVariation, in: loopLength)
        
        print("nextMIDIstartTime \(nextMIDIstartTime) nextVariation \(nextVariation) loopLength \(loopLength)")
        
        stopNotesTrackId(for: trackId)
        
        copyMIDIfromMemory(
            trackId: trackId,
            midiStartTime: nextMIDIstartTime,
            loopLength: loopLength[nextVariation])
    }
    
    public func playNoteNumberSingleTrack(
        trackId:String,
        soundSource: InstrumentsSet.Track.InstrumentType,
        noteNumber:Int,
        noteOn:Bool
    ){
        print("playNoteNumberSingleTrack \(trackId) \(soundSource) \(noteNumber) \(noteOn)")
        
        if !noteOn {
            playEngineUIEffect()
            
//            let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
//            trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: trackOn)
            
            let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(127), channel: 1)
            
            if [.exsSampler, .audioBuffer, .audioBufferTimed].contains(soundSource){
                
                trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
            }
            else if [.pulseWidthSynth, .phaseSynth].contains(soundSource) {
                
                trackInstruments[trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
            }
            
        } else {
            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
            
            if [.exsSampler, .audioBuffer, .audioBufferTimed].contains(soundSource){
                trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
            }
            else if [.pulseWidthSynth, .phaseSynth].contains(soundSource) {
                                
                trackInstruments[trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
            }
        }
    }
    
    //Volume buttons on boarding
    public func playNoteNumbersIntroduction(
        trackId:String,
        soundSource: InstrumentsSet.Track.InstrumentType,
        noteNumbers: [Int],
        noteOn:Bool
    ){
        if !noteOn {
            playEngineUIEffect()
            
//            let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
//            trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: trackOn)
            
            //Get any but the last played note
            let filteredNotes = noteNumbers.filter { $0 != self.lastNoteNumber }
            
            print("Available notes: \(filteredNotes)")
            
            if let noteNumber = noteNumbers.randomElement() {
                
                print("PLAYING \(noteNumber)")
                
                self.lastNoteNumber = noteNumber
                let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(100), channel: 1)
                self.trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
                
            }
            else{
                print("EEROR PLAYING. last was \(String(describing: self.lastNoteNumber))")
            }
            
        } else {
            
            for noteNumber in noteNumbers {
                
                let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
                
                trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
            }
        }
    }
    
    public func stopAllNoteNumbers( trackId:String ){
        for noteNumber in 0...127 {
            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
            
            if let trackSampler = trackSamplers[    trackId] {
                trackSampler.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
            } else {
                print("Index \(trackId) not found in trackSamplers array.")
            }
            
        }
    }
    
    //MARK: Level Controller / Mute status tracks
    
    //What does levelController do?
    //Called from
    //- SetInfoModel.startObservingData -> Level change
    //- Conductor.togglePlayEngineAndTracks -> Transport play and stop
    //- MainView SpriteKitView.onAppear -> spriteKitOnAppear
    //- Control if midiClips are controlled by level number
    //- Control play stop end of level
    //- Control playlist logic
    
    public func levelController(
        level selectedLevel: Int,
        setSettings: SetSettings
    ) -> Void {
        
//        print("levelController called")
        
        //MARK: Let know if levels is done
        //Highest level is full and is for the first time
        if selectedLevel == setSettings.levels.count &&  userSettings.isSetPlaying {
            
            //We stop playing
            self.pauzeEngineAndStopTracks(
                setSettings: setSettings,
                resetLevels: true
            )
            
            userSettings.isSetPlaying = false
            
            if setSettings.fileGroup == .playlists {
                let sounds = ["Applause01", "Applause02", "Applause03"]
                playInterfaceSounds(sounds: sounds, volume: 0.17)
            }
            
            if !autoVoice.isSpeaking {
                
                let utteranceText: String
                let utteranceRate: Float
                
                if setSettings.fileGroup == .playlists {
                    utteranceText = NSLocalizedString("Set complete", comment: "")
                    utteranceRate = 0.55
                } else {
                    // Specify a different utterance here
                    utteranceText = NSLocalizedString("Set ended", comment: "")
                    utteranceRate = 0.4
                }
                
                let trudy = AVSpeechUtterance(string: utteranceText)
                trudy.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("accent", comment: ""))
                trudy.rate = utteranceRate
                trudy.pitchMultiplier = 1.01
                trudy.volume = 0.60
                autoVoice.speak(trudy)
            }
        }
        
        //Is track in level playing logic
        setSettings.tracks.forEach { track in
            
            //MARK: midi clip based on level
            //Variation by level  select loops/notenumber toLevel for current level
            if track.value.variationType == .variationByLevel {
                
                if track.value.noteSource == .midiFile {
                    //midi files which play notes
                    levelMidiClipVariation(in: selectedLevel, on: track.value)
                    
                    //midi files which play stems (buffer sampler)
                }
                else if track.value.noteSource == .noteNumbers {
                    //TODO: same is midi files shich play stems
                    levelNoteNumberVariation(in: selectedLevel, on: track.value)
                }
            }
            
            
            //TODO: Switch level type switch of is nieuwe methode superieur?
            
//            //UN-Mute if track is within level
//            if track.value.levels.contains(selectedLevel)
//            {
//                let envOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
//                if let trackAmpEnvelope = trackAmpEnvelopes[track.value.trackId] {
//                    trackAmpEnvelope.scheduleMIDIEvent(event: envOn)
//                }
//                else{
//                    print("ERROR: un mute \(track.value.trackId) not found")
//                }
//                
//            }
//            //Mute all other occasions is after last level
//            else {
//                
//                let envOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
//                if let trackAmpEnvelope = trackAmpEnvelopes[track.value.trackId] {
//                    trackAmpEnvelope.scheduleMIDIEvent(event: envOff)
//                }
//                else{
//                    print("mute \(track.value.trackId) not found")
//                }
//            }
        }
    }
    
    func playInterfaceSounds(sounds: [String], volume: Float) {
        if let randomSound = sounds.randomElement() {
            //            print("Random sound selected: \(randomSound)")
            if let path = Bundle.main.path(forResource: "Samples/" + randomSound, ofType: "wav") {
                //                print("Path exists: \(path)")
                let url = URL(fileURLWithPath: path)
                //                print("URL is valid: \(url)")
                do {
                    autoSound = try AVAudioPlayer(contentsOf: url)
                    autoSound?.delegate = self.autoSound as? any AVAudioPlayerDelegate
                    autoSound?.volume = volume
                    autoSound?.prepareToPlay()
                    autoSound?.play()
                    
                } catch {
                    print("Error: could not play sound: \(error)")
                }
            } else {
                print("Failed to get path for resource.")
            }
        } else {
            print("Failed to select random sound.")
        }
    }
    
    func stopInterfaceSounds(){
        autoSound?.stop()
    }
    
    public func setTempo( tempoChange: Double) -> Double{
        
        currentTempo = self.currentTempo + tempoChange
        
        print("new tempo: \(currentTempo) BPM")
        
        //All sequences get this tempo
        for trackId in trackSequencers.keys {
            if trackSequencers[trackId] != nil {
                trackSequencers[trackId]!.setTempo(currentTempo)
            }
        }
        
        return currentTempo
    }
    
    public func resetTempo() -> Double {
        
        let tempo: Double = set.bpm
        
        print("reset tempo to: \(currentTempo) BPM")
        
        //All sequences get this tempo
        for trackId in trackSequencers.keys {
            if trackSequencers[trackId] != nil {
                trackSequencers[trackId]!.setTempo(tempo)
            }
        }
        
        return tempo
    }
    
    //MARK: MIDI events
    //Callback after MIDI event funcs
    internal func isVelocitySensitive(
        for track: InstrumentsSet.Track) -> Bool {
            
            var isVelocitySensitive = false
            
            if track.parts.count > 0 {
                for part in track.parts {
                    if part.damperTarget.parameter == "velocity" {
                        isVelocitySensitive = true
                    }
                }
            }
            return (isVelocitySensitive)
        }
    
    private func collectMidiChannels() -> [String: Int] {
        
        var midiTargetChannels: [String: Int] = [:]
        var i: Int = 1
        set.tracks.forEach { track in
            midiTargetChannels[track.id] = i
            i += 1
        }
        return midiTargetChannels
    }
    
    
    //MARK: Callback Instrument
    internal func callBackInstrument(
        for trackId: String,
        controlling sampler: MIDISampler,
        on midiChannel: Int
    ) -> MIDICallbackInstrument {
        
        //Sequencer to callback to play sampler
        let midiCallBackInstrument =  MIDICallbackInstrument { [self] status, note, velocity in
            
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            
            if midiStatus == .noteOn {
                
                //NOTE: midiStatus == .noteOn does not pass chords, just single notes
                //NOTE: if note off event is on same moment as note on, there will be no note on event
                
                let newVelocity = UInt8( max(Double(velocity) * velocities[trackId]!, 0 ))
                
                sampler.play(noteNumber: note, velocity: newVelocity, channel: MIDIChannel(midiChannel))
            }
            else if midiStatus == .noteOff {
                
                sampler.stop(noteNumber: note, channel: MIDIChannel(midiChannel))
            }
        }
        return midiCallBackInstrument
    }
    
    
    //MARK: Chain effects per track
    internal func chainEffects(
        for track: InstrumentsSet.Track,
        startingNode: Node) -> Node {
            
            guard let effects = track.effects else { return startingNode }
            var finalNode = startingNode
            effects.forEach { effect in
                
                finalNode = effect.chain(to: finalNode)
            }
            
            return finalNode as Node
        }
    
    //MARK: Add track amplitude envelopes
//    internal func setTrackAmpEnvelope(trackId: String, startingNode: Node) -> Node{
//        
//        //Add Amplitude envelope for
//        trackAmpEnvelopes[trackId] = AmplitudeEnvelope(startingNode)
//        trackAmpEnvelopes[trackId]!.attackDuration = 0.4
//        trackAmpEnvelopes[trackId]!.decayDuration = 0.01
//        trackAmpEnvelopes[trackId]!.sustainLevel = 1.0
//        trackAmpEnvelopes[trackId]!.releaseDuration = 0.4
//        
//        return trackAmpEnvelopes[trackId]! as Node
//    }
    
    //MARK: Chain master track
    private func chainMasterEffects(
        for effects: [InstrumentsSet.Track.Effect],
        startingNode: Node) -> Node {
            
            var finalNode = startingNode
            effects.forEach { effect in
                finalNode = effect.chain(to: finalNode)
            }
            
            return finalNode as Node
        }
    
    //MARK: Level increment
    /*
     Here we have level increment logic
     */
    
    internal func adjustCurrentSetLevel(
        setSettings: SetSettings,
        currentSetLevel: Double,
        averageMovement: Double
    ) -> Double {
        
        let doubleLevels = Double(setSettings.levels.count)
        
        //When levels go up levelspeed is decreased
        let speedAdjustmentFactor = currentSetLevel.transform(
            outputStart: 1.0,
            outputEnd: 0.1,
            inputStart: 0.0,
            inputEnd: doubleLevels,
            transformationDegree: 0
        )
        
        // Pas de userSettingLevelSpeed aan met de speedAdjustmentFactor.
        let setSettingLevelSpeed = setSettings.levelSpeedSet * speedAdjustmentFactor
        
        let movementThreshold = setSettings.levelDifficultySet.transform(
            outputStart: 0.1,
            outputEnd: 0.3,
            transformationDegree: 3
        )
        
        if averageMovement > movementThreshold {
            // Verhoog de level op basis van de beweging en gebruikersvoorkeur.
            let newSetLevel = currentSetLevel + setSettingLevelSpeed * averageMovement
            
            if let uuid = rewindIsPlaying {
                envelopeSamplerStop(uuid: uuid)
                rewindIsPlaying = nil
            }
            
            if !setSettings.isWavePlaying && userSettings.isSetPlaying {
                setSettings.isWavePlaying = true
                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                    playTrack($0)
                    
                    print("Start with movement track \($0.trackId)")
                }
            }
            
            if newSetLevel < doubleLevels {
                return newSetLevel
            } else { return doubleLevels - 0.001 }
            
        } else {
            
            let levelDecreaseRate = setSettings.levelSpeedSet * setSettings.levelDifficultySet.transform(
                outputStart: 0.1,
                outputEnd: 1,
                transformationDegree: 1
            )
            
            let nextCurrentSetLevel = max(currentSetLevel - levelDecreaseRate, 0.0)
            if nextCurrentSetLevel < 0.1 {
                
                if setSettings.isWavePlaying {
                    setSettings.isWavePlaying = false
                    setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                        stopTrack($0)
                        
                        print("Stop with no movement track \($0.trackId)")
                    }
                }
                
                if let uuid = rewindIsPlaying {
                    envelopeSamplerStop(uuid: uuid)
                    rewindIsPlaying = nil
                }
            }
            else{
                if rewindIsPlaying == nil {
                    if let uuid = envelopeSamplerPlay(
                        effectType: .rewind,
                        identifier: Int(nextCurrentSetLevel)
                    ) {
                        rewindIsPlaying = uuid
                    }
                }
            }
            return nextCurrentSetLevel
        }
    }

    private func levelMidiClipVariation(in level: Int, on track: TrackSettings) -> Void {
        
        if track.levels.contains(level) {
            
            //Midi clip looplength
            let clipLengths = track.loopLength
            let nextVariation = track.loopsToLevel[level]
            
            let nextMIDIstartTime = calculateMIDIstartTime(for: nextVariation, in: clipLengths)
            
            if nextVariation >= 0 && nextVariation < clipLengths.count {
                copyMIDIfromMemory(
                    trackId: track.trackId,
                    midiStartTime: nextMIDIstartTime,
                    loopLength: clipLengths[nextVariation]
                )
            } else {
                print("Error: index 'nextVariation' (\(nextVariation)) is out of range given array 'clipLengths'.")
            }
        }
    }
    
    private func levelNoteNumberVariation(in level: Int, on track: TrackSettings) -> Void {
        if track.levels.contains(level) {
            
            //            print("levelNoteNumberVariation -> copyMIDIfromMemory ")
            
            guard track.notesToLevel.contains(level) else{
                return
            }
            
            //Get length in beats from audio filws
            let clipLengths: [Double] = track.audioFiles.map { Double($0.lengthInBeats) }
            
            //            print("clipLengths: \(clipLengths)")
            
            let nextVariation = track.notesToLevel[level]
            
            //            print("nextVariation: \(nextVariation)")
            
            let nextMIDIstartTime = calculateMIDIstartTime(for: nextVariation, in: clipLengths)
            
            //            stopNotesTrackId(for: track.trackId)
            
            //            print("nextMIDIstartTime: \(nextMIDIstartTime)")
            //            print("loopLength: \(clipLengths[nextVariation])")
            
            copyMIDIfromMemory(
                trackId: track.trackId,
                midiStartTime: nextMIDIstartTime,
                loopLength: clipLengths[nextVariation]
            )
        }
    }
    
    internal func calculateMIDIstartTime(
        for currentTimeScore: Int,
        in loopLengths: [Double]
    ) -> Double {
        
        var currentMIDIstartTime: Double = 0.0
        if currentTimeScore > 0 {
            for (index,loopLength) in loopLengths.enumerated() {
                if index < currentTimeScore {
                    currentMIDIstartTime += loopLength
                }
            }
        }
        return currentMIDIstartTime
    }
    
    internal func copyMIDIfromMemory(trackId: String, midiStartTime: Double, loopLength: Double) {
        
        let contentFromMemory = trackSequencersMemory[trackId]?.tracks[0].getMIDINoteData()
        
        // isolate the segment for looping and shift it to the start of the track
        let loopSegment = contentFromMemory?.filter { midiStartTime ..< (midiStartTime + loopLength) ~= $0.position.beats }
        
        let shiftedSegment = loopSegment?.map { MIDINoteData(
            noteNumber: $0.noteNumber,
            velocity: $0.velocity,
            channel: $0.channel,
            duration: $0.duration,
            position: Duration(beats: $0.position.beats - midiStartTime)
        )
        }
        
        //All notes off is moved one layer up
        // replace the track contents with the loop, and assert the looping behaviour
        trackSequencers[trackId]?.tracks[0].replaceMIDINoteData(with: shiftedSegment!)
        trackSequencers[trackId]?.setLength(Duration(beats: loopLength))
        trackSequencers[trackId]?.setLoopInfo(Duration(beats: loopLength), loopCount: 0)
        trackSequencers[trackId]?.enableLooping()
    }
    
    //MARK: Transport
    internal func stopNotesTrackId(for trackId: String) {
        
        //Shut down all note on's
        if let trackSampler = trackSamplers[trackId] {
            // Shut down all note on's
            for note in 0...127 {
                trackSampler.stop(noteNumber: MIDINoteNumber(note), channel: 1)
            }
        } else {
            print("trackSamplers[\(trackId)] is nil")
        }
    }
    
    internal func playEngineAndTracks(
        setSettings: SetSettings,
        level: Int
    ) {
        
        do {
            //Variable for use Everywhere
            userSettings.isSetPlaying = true
            
            //Fire up the audio engine
            try audioEngine.start()
            
            print("--> We're playing <--")
            
            setSettings.tracks.forEach { track in
                
                //Both midi file and audioBuffer note numbers
                if track.value.startType == .loopedTransport {
                    playTrack(track.value)
                }
                
                //                if track.value.variationType == .variationSequencial {
                //                    
                //                    let currentNote = sequenceNote[track.value.trackId] ?? track.value.midiGroup.first!
                //                    let noteNumber = getNextSequenceNote(
                //                        currentNote,
                //                        track.value.notesSequenceType,
                //                        track.value.midiGroup,
                //                        0.5
                //                    )
                //                    playNoteNumber(track.value, noteNumber)
                //                }
            }
        } catch {
            print("Catched playEngineAndTracks \(error)")
        }
    }
    
    internal func startRecordingTracks(
        setSettings: SetSettings
    ){
        do {
            try setSettings.tracks.forEach { track in
                
                try trackRecorders[track.value.trackId]?.record()
                
                print("RECORDING \(track.value.trackName)")
            }
            
            //            try masterRecorder?.record()
            
            print("RECORDING master")
            
        }
        catch {
            print("Error startRecordingTracks \(error)")
        }
    }
    
    internal func stopRecordingTracks(
        setSettings: SetSettings
    ){
        
        //        masterRecorder?.stop()
        //        print("STOP RECORDING master")
        
        setSettings.tracks.forEach { track in
            
            trackRecorders[track.value.trackId]?.stop()
        }
    }
    
    public func pauzeEngineAndStopTracks(
        setSettings: SetSettings,
        resetLevels: Bool
    ) {
        
        //Fade out
        if resetLevels {
            levelController(
                level: -1,
                setSettings: setSettings
            )
        }
        
        setSettings.tracks.values.forEach {
            
            stopTrack($0)
            
            for noteNumber in 0...127 {
                stopSamplerNote($0, noteNumber)
            }
        }
        
        if let samplers = effectSamplers {
            for (_, sampler) in samplers {
                let noteNumber = 60
                let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
                sampler.scheduleMIDIEvent(event: noteOff)
            }
        }
    }
    
    private func playEngineUIEffect() {
        do {
            //Fire up the audio engine
            try audioEngine.start()
        } catch {
            print("Engine not started")
        }
    }
}
