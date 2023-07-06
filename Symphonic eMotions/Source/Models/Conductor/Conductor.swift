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
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    
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
    
    //trackSequencers holds MIDI file information
    //Is the play head in the score
    //Controls speed, loop (length)
    //The playhead only moves lineair
    internal var trackSequencers: [String: AppleSequencer] = [:]
    //To move the playhead to another part in the score:
    //Copy part to move to current length playing
    internal var trackSequencersMemory: [String: AppleSequencer] = [:]
    //Modifying midi like velocity
    private var trackSequencersCallbackers: [String: MIDICallbackInstrument] = [:]
    //Velocities per track to be controlled by intrumentParts
    internal var velocities: [String: Double] = [:]
    //Modify tempo while playing
    private var currentTempo: Double = 0
    
    
    //MARK: InstrumentTypes
    internal var soundModuleParam01: [String: Double] = [:]
    internal var soundModuleParam02: [String: Double] = [:]
    internal var soundModuleVolume: [String: Double] = [:]
    
    
    //MARK: Therapist editor variables
    //Ramp values containers stored per Instrument.Part
    public var rampValues: [String: Double] = [:]
    //Ramp up and Ramp down values from struct and control from editor
    public var rampUp: [String: Double] = [:]
    public var rampDown: [String: Double] = [:]
    //Volume also controlled by editor
    public var volume: [String: Double] = [:]
    
    //Sampler container
    internal var trackSamplers: [String: MIDISampler] = [:]
    //Synth container
    private var trackInstruments: [String: Node] = [:]
    
    //Sampler for interface audio
    //TODO: this needs to get plugged into the second mixer next to Mastertrack effects
    private var soundEffectSampler: MIDISampler = MIDISampler(name: "Sound Effects")
    
    //Amplitude enelopes for muting tracks for levels
    //TODO: init of these needs to be at 0 (-90Db)
    private var trackAmpEnvelopes: [String: AmplitudeEnvelope] = [:]
    
    // Keep track of currently playing notes and their end times (playNoteNumberLength)
    internal var endTimesNotes: [String: [Int: Duration]] = [:]
    //Keep track of current note for note sequences
    internal var sequenceNote: [String: Int] = [:]
    
    //MARK: Combine variables for communication to user interface
    //Global for the status control and feedback of this class
//    var isConductorPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    
    //Intermediair for sending data back to interface, visual feedback
    var forwardRampedPartFeedback = CurrentValueSubject<Double, Never>(0)
    
    //InstrumentParts to SpriteKit through PassthroughSubject
    var spriteKitParts0a = PassthroughSubject<(Int,Int,Double), Never>()
    var spriteKitParts0b = PassthroughSubject<(Int,Int,Double), Never>()
    var spriteKitParts1a = PassthroughSubject<(Int,Int,Double), Never>()
    var spriteKitParts1b = PassthroughSubject<(Int,Int,Double), Never>()
    var spriteKitParts2a = PassthroughSubject<(Int,Int,Double), Never>()
    var spriteKitParts2b = PassthroughSubject<(Int,Int,Double), Never>()
    var spriteKitParts3a = PassthroughSubject<(Int,Int,Double), Never>()
    var spriteKitParts3b = PassthroughSubject<(Int,Int,Double), Never>()
    
    //The main instrument set structure. A Musical set is loaded into this struct
    internal var set: InstrumentsSet
    
    //Timer for introduction repeater:
    var timer: Timer?
    var lastNoteNumber: Int?
    
    //MARK: Init
    init(set: InstrumentsSet) {
        
        self.set = set
        
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
        trackAmpEnvelopes = [:]
        rampUp = [:]
        rampDown = [:]
        volume = [:]
        trackSamplers = [:]
        trackSequencersCallbackers = [:]
        trackSequencers = [:]
        trackSequencersMemory = [:]
        trackInstruments = [:]
    }
    
    //Function which is called when switching between sets
    public func currentConductorInstrumentsSetChanged(
        newInstrumentsSet: InstrumentsSet,
        currentSetLevel: Double,
        setSettings: SetSettings
    ) {
        pauzeEngineAndStopTracks(setSettings:setSettings)
        
        currentTempo = newInstrumentsSet.bpm
        
        set.tracks.forEach { track in
            
            //Replace all EXS files with the empty trigger.exs to prefent too many files open
            //Remove exs from memory
            if trackSamplers[track.id] != nil {
                
                if let notesArePlaying = setSettings.tracks[track.id]?.notesArePlaying {
                    
                    for note in notesArePlaying {
                        let noteOff = MIDIEvent(noteOn: MIDINoteNumber(note), velocity: 0, channel: 1)
                        trackSamplers[track.id]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
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
            
            if( trackAmpEnvelopes[track.id] != nil ) {
                trackAmpEnvelopes.removeValue(forKey: track.id)
                trackAmpEnvelopes[track.id] = nil
            }
        }
        
        mixer.removeAllInputs()
        mixerMaster.removeAllInputs()
        
        setInitialState()
        set = newInstrumentsSet
        
        loadTracks(currentSetLevel: currentSetLevel)
        
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
        
        //Create tupple with midichannel per midi only instrument
        var midiChannels = collectMidiChannels()
        
        set.tracks.forEach { track in
            
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
                }
            }
            velocities[track.id] = startVelocity
            
            //NoteEndTimes
            endTimesNotes[track.id] = [:]
            //sequenceNotes
            sequenceNote[track.id] = 0
            
            //Load sequencers
            //Within this function the EXS is also loaded
            trackSequencersCallbackers[track.id] = nil
            trackSequencers[track.id] = midiSequencer(
                for: track,
                length: "loop",
                currentSetLevel: currentSetLevel,
                midiChannels: &midiChannels,
                samplePath: set.filesPath
            )
            
            //Make dummy connectors for memory sequences to silence them in triggers module
            var midiChannelsDummy: [String: Int] = [:]
            trackSequencersMemory[track.id] = midiSequencer(
                for: track,
                length: "all",
                currentSetLevel: currentSetLevel,
                midiChannels: &midiChannelsDummy,
                samplePath: set.filesPath
            )
            
            soundModuleParam01[track.id] = 0
            soundModuleParam02[track.id] = 0
            soundModuleVolume[track.id] = 0
            
            //Turn tracks off so things will be quiet to start off with
            if let trackAmpEnvelope = trackAmpEnvelopes[track.id] {
                let envOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
                trackAmpEnvelope.scheduleMIDIEvent(event: envOff)
            } else {
                print("trackAmpEnvelopes[track.id] is nil")
            }
        }
    }
    
    //Playing a sound effect at this moment is not working well with switching sets
    public func playSoundEffect(midi noteNumer: MIDINoteNumber){
        
        playEngineUIEffect()
        
        let noteOn = MIDIEvent(noteOn: noteNumer, velocity: 100, channel: 1)
        soundEffectSampler.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
        
        let noteOff = MIDIEvent(noteOn: noteNumer, velocity: 0, channel: 1)
        let samples = UInt64(3 * Settings.sampleRate)
        soundEffectSampler.scheduleMIDIEvent(event: noteOff, offset: samples)
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
                //                unMuteTrack(trackId: trackId)
                let envOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
                trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: envOn)
                
                velocities[trackId] = 1.0
                
                print("play \(trackId)")
                
                trackSequencers[trackId]?.play()
            }
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
        if !noteOn {
            playEngineUIEffect()
            
            let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
            trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: trackOn)
            
            let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(127), channel: 1)
            
            if [.exsSampler, .audioBuffer, .audioBufferTimed].contains(soundSource){
                trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
            }
            else if [.pulseWidthSynth, .phaseSynth].contains(soundSource) {
                
                print(noteOn)
                
                trackInstruments[trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
            }
            
        } else {
            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
            
            if [.exsSampler, .audioBuffer, .audioBufferTimed].contains(soundSource){
                trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
            }
            else if [.pulseWidthSynth, .phaseSynth].contains(soundSource) {
                
                print(noteOff)
                
                trackInstruments[trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
            }
        }
    }
    
    public func playNoteNumbersIntroduction(
        trackId:String,
        soundSource: InstrumentsSet.Track.InstrumentType,
        noteNumbers: [Int],
        noteOn:Bool
    ){
        if !noteOn {
            playEngineUIEffect()
            
            let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
            trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: trackOn)
            
            
            if let noteNumber = noteNumbers.randomElement() {
                self.lastNoteNumber = noteNumber
                let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(100), channel: 1)
                self.trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
                //Never play same note twice
                var newNoteNumber: Int? = nil
                repeat {
                    newNoteNumber = noteNumbers.randomElement()
                } while newNoteNumber == self.lastNoteNumber
                
                if let noteNumber = newNoteNumber {
                    self.lastNoteNumber = noteNumber
                    let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(100), channel: 1)
                    self.trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
                }
            }
        } else {
            
            timer?.invalidate()
            timer = nil
            
            for noteNumber in noteNumbers {
                
                let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
                
                trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
            }
        }
    }
    
    public func stopAllNoteNumbers( trackId:String ){
        for noteNumber in 0...127 {
            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
            trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
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
        
        //Run over all tracks
        setSettings.tracks.forEach { track in
            
            //Variation by level  select loops/notenumber toLevel for current level
            if track.value.variationType == .variationByLevel {
                if track.value.noteSource == .midiFile {
                    levelMidiClipVariation(in: selectedLevel, on: track.value)
                }
                else if track.value.noteSource == .noteNumbers {
                    levelNoteNumberVariation(in: selectedLevel, on: track.value)
                }
            }
            
            //UN-Mute if track is within level
            if track.value.levels.contains(selectedLevel)
            {
                let envOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
                trackAmpEnvelopes[track.value.trackId]!.scheduleMIDIEvent(event: envOn)
            }
            //Mute all other occasions is after last level
            else {
                
                let envOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
                trackAmpEnvelopes[track.value.trackId]!.scheduleMIDIEvent(event: envOff)
                
                //Highest level is full and is for the first time
                if selectedLevel == setSettings.levels.count &&  isSetPlaying {
                    
                    //We stop playing
                    self.pauzeEngineAndStopTracks(setSettings: setSettings)
                    
                    let sounds = ["Applause01", "Applause02", "Applause03"]
                    playInterfaceSounds(sounds: sounds, volume: 0.30)
                    
                    if !autoVoice.isSpeaking {
                        
                        let trudy = AVSpeechUtterance(string: NSLocalizedString("Set complete", comment: ""))
                        trudy.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("accent", comment: ""))
                        trudy.rate = 0.55
                        trudy.pitchMultiplier = 1.01
                        trudy.volume = 0.78
                        autoVoice.speak(trudy)
                    }
                }
            }
        }
    }
    
    func playInterfaceSounds(sounds: [String], volume: Float) {
        if let randomSound = sounds.randomElement() {
            print("Random sound selected: \(randomSound)")
            if let path = Bundle.main.path(forResource: "Samples/" + randomSound, ofType: "wav") {
                print("Path exists: \(path)")
                let url = URL(fileURLWithPath: path)
                print("URL is valid: \(url)")
                do {
                    autoSound = try AVAudioPlayer(contentsOf: url)
                    autoSound?.delegate = self.autoSound as? any AVAudioPlayerDelegate
                    autoSound?.prepareToPlay()
                    autoSound?.play()
                    autoSound?.volume = volume
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
    
    // MARK: Seqs & Sound gens
    private func midiSequencer(
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
                    
                    let fileURL = documentsDirectory.appendingPathComponent("\(set.filesPath)/\(midiFile.fileName)")
                    
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
            
            //Default length of 1 loop, for midi memory we need the length of "all" loops, thus the sum of loops
            var duration = Duration(beats: midiFile.loopLength.first ?? 0)
            
            if length == "all" {
                
                //Over write loop duration
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
            
            //loop means, we have an actual instrument, not a sequencer loaded for copy reference
            if length == "loop" {
                
                switch track.instrumentType {
                    
                case .exsSampler:
                    
                    //Create EXS sampler
                    trackSamplers[track.id] = createExsSampler(for: track, and: sequencer)
                    
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
                    
                    trackSamplers[track.id] = createAudioBufferSampler(
                        for: track,
                        and: sequencer,
                        currentSetLevel: currentSetLevel,
                        samplePath: samplePath
                    )
                    
                case .audioBufferTimed:
                    trackSamplers[track.id] = createAudioBufferTimePitch(
                        for: track,
                        and: sequencer,
                        currentSetLevel: currentSetLevel,
                        targetBPM: set.bpm,
                        samplePath: samplePath
                    )
                case .pulseWidthSynth:
                    trackInstruments[track.id] = createPulseWidthSynth(for: track, and: sequencer)
                case .phaseSynth:
                    trackInstruments[track.id] = createPhaseSynth(for: track, and: sequencer)
                }
            }
            
            return sequencer
        }
    
    //MARK: MIDI events
    //Callback after MIDI event funcs
    private func isVelocitySensitive(
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
    private func callBackInstrument(
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
    internal func setTrackAmpEnvelope(trackId: String, startingNode: Node) -> Node{
        
        //Add Amplitude envelope for
        trackAmpEnvelopes[trackId] = AmplitudeEnvelope(startingNode)
        trackAmpEnvelopes[trackId]!.attackDuration = 0.4
        trackAmpEnvelopes[trackId]!.decayDuration = 0.01
        trackAmpEnvelopes[trackId]!.sustainLevel = 1.0
        trackAmpEnvelopes[trackId]!.releaseDuration = 0.4
        
        return trackAmpEnvelopes[trackId]! as Node
    }
    
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
    
    //MARK: Forward Master Track
    public func forwardMasterTrackEffect(value: Double, nodeName: String, parameter: String, parameterRange: [Double] ) {
        
        let effectType = InstrumentsSet.Track.Effect.EffectType(rawValue: nodeName)
        
        let effect = set.effect(for: effectType!)
        
        effect!.targetAndApply(value: value, nodeName: nodeName, parameter: parameter, parameterRange: parameterRange)
    }
    
    //MARK: Level increment
    /*
     Here we have level increment logic
     */
    
    internal func getAndOrIncreaseCurrentSetLevel(
        currentSetLevel: Double,
        value: Double ) -> Double {
            
            if value > 0.1 {
                
                //Hack to get initial value after first install
                //Problem is this triggering every frame
                var userDefaultsLevelSpeed = UserDefaults.standard.double(forKey: "levelSpeed") * 0.4
                
                if userDefaultsLevelSpeed == 0 {
                    userDefaultsLevelSpeed = 0.1
                }
                
                //Level speed slider from sheet correlation
                let levelSpeedValue = currentSetLevel + 0.01 * userDefaultsLevelSpeed * value
                
                // Muting is not happening in over amount of levels.
                return levelSpeedValue
            }
            
            return currentSetLevel
        }
    
    private func levelMidiClipVariation(in level: Int, on track: TrackSettings) -> Void {
        
        if track.levels.contains(level) {
            
            guard track.loopsToLevel.contains(level) else{
                return
            }
            
            //Midi clip looplength
            let clipLengths = track.loopLength
            let nextVariation = track.loopsToLevel[level]
            
            let nextMIDIstartTime = calculateMIDIstartTime(for: nextVariation, in: clipLengths)
            
            stopNotesTrackId(for: track.trackId)
            
            copyMIDIfromMemory(
                trackId: track.trackId,
                midiStartTime: nextMIDIstartTime,
                loopLength: clipLengths[nextVariation]
            )
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
    private func envDownTracks(_ track: TrackSettings) {
        let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
        trackAmpEnvelopes[track.trackId]!.scheduleMIDIEvent(event: trackOff)
    }
    
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
    
    internal func togglePlayEngineAndTracks(
        currentSetLevel: Double,
        setSettings: SetSettings
    ) {
        
        if isSetPlaying {
            
            //Fade out
            levelController(
                level: -1,
                setSettings: setSettings
            )
            
            //We stop playing
            self.pauzeEngineAndStopTracks(setSettings: setSettings)
            
        }
        else {
            print("Mute here before play?")
            
            //Fade in on master play, we need level.currentlevel here
            levelController(
                level: Int(currentSetLevel),
                setSettings: setSettings
            )
            
            playEngineAndTracks(
                setSettings: setSettings,
                level: Int(currentSetLevel)
            )
            
            
        }
    }
    
    internal func playEngineAndTracks(
        setSettings: SetSettings,
        level: Int
    ) {
        
//        guard !isConductorPlayingSubject.value else { return }
        
        do {
            //Variable for use Everywhere
            isSetPlaying = true
            
            //Fire up the audio engine
            try audioEngine.start()
            
            print("--> We're playing <--")
            
            setSettings.tracks.forEach { track in
                //Both midi file and audioBuffer note numbers
                
                if track.value.startType == .loopedTransport {
                    playTrack(track.value)
                }
                
                if track.value.variationType == .variationSequencial {
                    
                    let currentNote = sequenceNote[track.value.trackId] ?? track.value.midiGroup.first!
                    let noteNumber = getNextSequenceNote(
                        currentNote,
                        track.value.notesSequenceType,
                        track.value.midiGroup,
                        0.5
                    )
                    playNoteNumber(track.value, noteNumber)
                }
            }
        } catch {
            print("Catched \(error)")
        }
    }
    
    public func pauzeEngineAndStopTracks(setSettings: SetSettings) {
        
        isSetPlaying = false
        
        print("SET ID PLAYING 001 \(isSetPlaying)")
        
        setSettings.tracks.values.forEach {
            
            envDownTracks($0)
            
            if $0.noteSource == .midiFile { stopTrack($0) }
            if $0.noteSource == .noteNumbers {
                for note in $0.notesArePlaying {
                    stopNoteNumber($0, note)
                }
            }
        }
        
        //No ticks between tracks, but there are audio tailes
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //            self.audioEngine.pause()
        //        }
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
