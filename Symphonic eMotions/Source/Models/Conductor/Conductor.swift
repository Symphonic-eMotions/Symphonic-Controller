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

final class Conductor {
    
    //MARK: Var declarations
    //Audiokit AudioEngine. One engine is running at all times
    //Gets pauzed on set change
    private var audioEngine: AudioEngine
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
    private var trackSequencersMemory: [String: AppleSequencer] = [:]
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
    
    
    //MARK: StartTypes
    internal var trackWaveActive: [String: Bool] = [:]
    internal var scorePartWatingToChange: [String: Double] = [:]
    //Value to calculate direction of intensity of movement
    internal var trackWavePreviousValue: [String: Double] = [:]
    //Holds notes which are used in sequencer replacement.
    //This is the basis of an Arpegiator
    //"note number index (midiData group)" and note number combination
    internal var midiDataGroupNoteNumbers: [String: [Int]] = [:]
    internal var midiDataGroupIndex: [String: [Int]] = [:]
    
    
    //MARK: ValuesDidChange per Instrument Part
    //Ramp values containers stored per Instrument.Part
    public var rampValues: [String: Double] = [:]
    //Ramp up and Ramp down values from struct and control from editor
    public var rampUp: [String: Double] = [:]
    public var rampDown: [String: Double] = [:]
    //Volume also controlled by editor
    public var volume: [String: Double] = [:]
    
    //MARK: Current played midi clip per track
    private var globalCurrentMIDIclip: [String: Int] = [:]
    //maxIndexParts holds the position controls clip grid
    private var maxIndexParts: [String: Int] = [:]
    
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

    //MARK: Combine variables for communication to user interface
    //Global for the status control and feedback of this class
    var isConductorPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    
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

    //MARK: Init
    init(set: InstrumentsSet) {
        
        self.set = set
        
        audioEngine = AudioEngine()
        mixer = Mixer()
        mixerMaster = Mixer()
        loadMaster(mixer: mixer)
        audioEngine.output = mixerMaster
        loadTracks(currentSetLevel: 0)
        
        //TODO: Don't load sound effects in .zorg
//        loadSoundEffects()
    }
    
    //Function to reset variables, is called on change of set
    public func setInitialState() {
        velocities = [:]
        soundModuleParam01 = [:]
        soundModuleParam02 = [:]
        soundModuleVolume = [:]
        globalCurrentMIDIclip = [:]
        scorePartWatingToChange = [:]
        trackWaveActive = [:]
        trackWavePreviousValue = [:]
        midiDataGroupNoteNumbers = [:]
        midiDataGroupIndex = [:]
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
                
                //Stop all running processes
                if let previousNoteNumbers = midiDataGroupNoteNumbers[track.id] ?? nil {
                    for noteNumber in previousNoteNumbers {
                        let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
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
        
        //TODO: Load based on build settings
//        loadSoundEffects()
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
            
            print("Load track \(track.id) Levels: \(String(describing: track.levels))")
            
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
//                    rampValues[part.id] = 0.0
                    rampUp[part.id] = part.damperTarget.nodeSettings!.rampSpeed ?? -1
                    rampDown[part.id] = part.damperTarget.nodeSettings!.rampSpeedDown ?? -1
                    maxIndexParts[part.id] = 0
                }
            }
            velocities[track.id] = startVelocity
            
            //Load sequencers
            //Within this function the EXS is also loaded
            trackSequencersCallbackers[track.id] = nil
            trackSequencers[track.id] = midiSequencer(
                for: track,
                   length: "loop",
                   currentSetLevel: currentSetLevel,
                   midiChannels: &midiChannels
            )
            
            //Make dummy connectors for memory sequences to silence them in triggers module
            var midiChannelsDummy: [String: Int] = [:]
            trackSequencersMemory[track.id] = midiSequencer(
                for: track,
                   length: "all",
                   currentSetLevel: currentSetLevel,
                   midiChannels: &midiChannelsDummy
            )
            
            //Turn tracks off so things will be quiet to start off with
            let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
            trackAmpEnvelopes[track.id]!.scheduleMIDIEvent(event: trackOff)
            muteTrack(trackId: track.id)
                        
            soundModuleParam01[track.id] = 0
            soundModuleParam02[track.id] = 0
            soundModuleVolume[track.id] = 0
            
            midiDataGroupNoteNumbers[track.id] = []
            midiDataGroupIndex[track.id] = [0]
            
            globalCurrentMIDIclip[track.id] = 0
            
            scorePartWatingToChange[track.id] = 0
            trackWavePreviousValue[track.id] = 0
        }
    }
    
    //Interaction sound library
    //TODO: needs controller
    private func loadSoundEffects(){
        
        let exsFile = "SoundEffects"
        soundEffectSampler.amplitude = -10
        mixer.addInput(soundEffectSampler)
        
        do {
            
            try soundEffectSampler.loadEXS24("Sounds/Sampler Instruments/\(exsFile)")
        } catch {
            print("Error loading EXS: \(exsFile)")
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
    public func previewSingleTrack(trackId: String){
        if trackSequencers[trackId] != nil {
            let isPLaying = trackSequencers[trackId]!.isPlaying
            
            if isPLaying {
                
                for note in 0...127 {
                    trackSamplers[trackId]!.stop(noteNumber: MIDINoteNumber(note), channel: 1)
                }
                trackSequencers[trackId]?.stop()
                trackSequencers[trackId]?.rewind()
                trackSequencers[trackId]?.preroll()
                
//                let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
//                trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: trackOff)

                
//                audioEngine.pause()
            }
            else{
                playEngineUIEffect()
//                unMuteTrack(trackId: trackId)
                let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
                trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: trackOn)
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
        
        stopNotesTrackId(for: trackId)
        
        copyMIDIfromMemory(
            trackId: trackId,
            midiStartTime: nextMIDIstartTime,
            loopLength: loopLength[nextVariation])
        
        globalCurrentMIDIclip[trackId] = nextVariation
    }
    
    public func playNoteNumberSingleTrack(trackId:String,noteNumber:Int,noteOn:Bool){
        
        if !noteOn {
            playEngineUIEffect()
            
            let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
            trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: trackOn)

            let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(127), channel: 1)
            trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
        
        } else {
            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(0), channel: 1)
            trackSamplers[trackId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
            
//            let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
//            trackAmpEnvelopes[trackId]!.scheduleMIDIEvent(event: trackOff)
        }
    }
    
    //MARK: Mute status tracks
    //TODO: switch sound off on set init
    
    //What does trackMuteAndClipStatusPerLevelControl do?
    //Called from
    //- PlayViewModel.startObservingData -> Level change
    //- Conductor.togglePlayEngineAndTracks -> Transport play and stop
    //- MainView SpriteKitView.onAppear -> spriteKitOnAppear
    //Control if midiClips are controlled by level number
    
    
    public func trackMuteAndClipStatusPerLevelControl(
        level selectedLevel: Int,
        setSettings: SetSettings,
        from source: String) -> Void {
        
        print("MUTING and LevelChange variation")
            
        //Run over all tracks
        set.tracks.forEach { track in
            
            //For all tracks, move up a clip modulo amount of clips
            if setSettings.tracks[track.trackId]!.trackType == .variationByLevel && source == "levelChange" {
                
                stopNotesTrackId(for: track.trackId)
                
                levelMidiClipVariation(in: selectedLevel, on: track)
            }
            
            //UN-Mute
            if setSettings.tracks[track.id]!.levels.contains(selectedLevel)
            {
                let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
                trackAmpEnvelopes[track.id]!.scheduleMIDIEvent(event: trackOn)
//                unMuteTrack(trackId: track.id)
            }
            //Mute
            else {
                let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
                trackAmpEnvelopes[track.id]!.scheduleMIDIEvent(event: trackOff)
//                muteTrack(trackId: track.id)
                
            }
        }
    }
    
    public func muteTrack( trackId: String){
        for (index, track) in set.tracks.enumerated() {
            if track.id == trackId {
                set.tracks[index].muted = true
            }
        }
    }
    
    public func unMuteTrack( trackId: String){
        for (index, track) in set.tracks.enumerated() {
            if track.id == trackId {
                set.tracks[index].muted = false
            }
        }
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
        midiChannels: inout [String: Int]) -> AppleSequencer? {
            
            // Use the 1st midi file defined.
            guard let midiFile = track.midiFiles?.first else {
                print("No MIDI file for track id: \(track.id)")
                return nil
            }
            
            let sequencer = AppleSequencer()
            sequencer.loadMIDIFile("Sounds/MIDI/\(set.filesPath)/\(midiFile.fileName)")
            sequencer.setTempo(set.bpm)
            
            //Default length of 1 loop, for midi memory we need the length of "all" loops, thus the sum of loops
            var duration = Duration(beats: midiFile.loopLength.first ?? 0)
            if length == "all" {
                duration = Duration(beats: midiFile.loopLength.reduce(0, {sum, value in sum + value}) )
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
                    trackSamplers[track.id] = createAudioBufferSampler(for: track, and: sequencer, currentSetLevel: currentSetLevel)
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
    
//    private func tempoRange(
//        for track: InstrumentsSet.Track) -> (Double,Double) {
//
//            var tempoLow = set.bpm
//            var tempoHigh = set.bpm
//            if track.parts.count > 0 {
//                for part in track.parts {
//                    if part.damperTarget.parameter == "tempo" &&
//                        part.damperTarget.nodeSettings?.tempoLow != nil &&
//                        part.damperTarget.nodeSettings?.tempoHigh != nil{
//
//                        tempoLow = part.damperTarget.nodeSettings?.tempoLow ?? set.bpm
//                        tempoHigh = part.damperTarget.nodeSettings?.tempoHigh ?? set.bpm
//                    }
//                }
//            }
//            return (tempoLow,tempoHigh)
//        }
    
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
        trackAmpEnvelopes[trackId]!.attackDuration = 1.5
        trackAmpEnvelopes[trackId]!.decayDuration = 0.01
        trackAmpEnvelopes[trackId]!.sustainLevel = 1.0
        trackAmpEnvelopes[trackId]!.releaseDuration = 1.5
            
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

    private func valueIndexChanged(maxIndex: Int, trackId: String) -> Bool{
        if maxIndexParts[trackId] != maxIndex {
            maxIndexParts[trackId] = maxIndex
            return true
        }
        return false
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
        levelSpeed: Double,
        currentSetLevel: Double,
        value: Double ) -> Double {
            
        if value > 0.1 {
            
            let levelSpeedValue = currentSetLevel + (levelSpeed/50) * value
            
            // Make sure we never "jump" at a value equal or greater to the number of levels - this will cause all tracks to mute
            return min(Double(set.levels.count) - 0.0000001, levelSpeedValue)
        }
        
        //0 ----> 1 Level part = 60 translates to 0.6 parts
        return currentSetLevel
    }
    
    private func levelMidiClipVariation( in level: Int, on track: InstrumentsSet.Track) -> Void {
        
        let clipLengths = track.midiFiles!.first!.loopLength
        let nextVariation = track.midiFiles?.first!.loopsToLevel[level] ?? 0
        let nextMIDIstartTime = calculateMIDIstartTime(for: nextVariation, in: clipLengths)
        
        stopNotesTrackId(for: track.id)
        
        copyMIDIfromMemory(
            trackId: track.id,
            midiStartTime: nextMIDIstartTime,
            loopLength: clipLengths[nextVariation])
        
        globalCurrentMIDIclip[track.id] = nextVariation
    }
    
    private func calculateMIDIstartTime(
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
    
    private func copyMIDIfromMemory(trackId: String, midiStartTime: Double, loopLength: Double) {
        
        let contentFromMemory = trackSequencersMemory[trackId]?.tracks[0].getMIDINoteData()
        
        // isolate the segment for looping and shift it to the start of the track
        let loopSegment = contentFromMemory?.filter { midiStartTime ..< (midiStartTime + loopLength) ~= $0.position.beats }
        
        let shiftedSegment = loopSegment?.map { MIDINoteData(noteNumber: $0.noteNumber,
                                                             velocity: $0.velocity,
                                                             channel: $0.channel,
                                                             duration: $0.duration,
                                                             position: Duration(beats: $0.position.beats - midiStartTime))
        }
        //All notes off is moved one layer up
        // replace the track contents with the loop, and assert the looping behaviour
        trackSequencers[trackId]?.tracks[0].replaceMIDINoteData(with: shiftedSegment!)
        trackSequencers[trackId]?.setLength(Duration(beats: loopLength))
        trackSequencers[trackId]?.setLoopInfo(Duration(beats: loopLength), loopCount: 0)
        trackSequencers[trackId]?.enableLooping()
    }

    internal func switchTrackMidiPart(_ track: InstrumentsSet.Track, _ maxIndex: Int) {
        //This function gets called when the index of the cell with most movement changes
        //Given are the
        // - amount of movement on the moment of the switch
        // - The new index with most movement on the mooment of change
        // - The track reference object to get to midiFiles, looplengths
        // Midi files follow this patern: A1,B1,C1,D1,A2,B2,C2,D2
        
        let loopLength = track.midiFiles![0].loopLength
        
        //Max index is the current most played index of the instrument locations (cells)
        let loopLengthIndex = maxIndex % loopLength.count
        
        let nextMIDIstartTime = calculateMIDIstartTime(for: loopLengthIndex, in: loopLength)
    
        copyMIDIfromMemory(
            trackId: track.trackId,
            midiStartTime: nextMIDIstartTime,
            loopLength: loopLength[loopLengthIndex])
    }
    
    //MARK: Transport
    private func envDownTracks(_ track: TrackSettings) {
        let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
        trackAmpEnvelopes[track.trackId]!.scheduleMIDIEvent(event: trackOff)
    }
    
    private func stopNotesTrackId(for trackId: String) {
        
        //Shut down all note on's
        for note in 0...127 {
            trackSamplers[trackId]!.stop(noteNumber: MIDINoteNumber(note), channel: 1)
        }
    }
    
    internal func togglePlayEngineAndTracks(
        currentSetLevel: Double,
        setSettings: SetSettings
    ) {
        
        if isConductorPlayingSubject.value {
            pauzeEngineAndStopTracks(setSettings: setSettings)
            
        }
        else {
            print("Mute here before play?")
            
            playEngineAndTracks(setSetting: setSettings)
            
            //Fade in on master play, we need level.currentlevel here
            trackMuteAndClipStatusPerLevelControl(
                level: Int(currentSetLevel),
                setSettings: setSettings,
                from: "togglePlay"
            )
        }
    }
    
    internal func playEngineAndTracks(setSetting: SetSettings) {
        
        guard !isConductorPlayingSubject.value else { return }
        
        do {
            //Variable for use in View (SwiftUI)
            isConductorPlayingSubject.send(true)
            
            //Fire up the audio engine
            try audioEngine.start()
            
            let startTypes: [StartType] = [.loopedTransport]
            setSetting.tracks.values.filter { startTypes.contains($0.startType) }.forEach {
                if $0.noteSource == .midiFile { playTrack($0) }
                if $0.noteSource == .noteNumbers { playNoteNumber($0) }
            }
        } catch {
            isConductorPlayingSubject.send(false)
        }
    }
    
    // Play a track
    internal func playTrack(_ track: TrackSettings) {
        trackSequencers[track.trackId]?.play()
    }
    
    // Stop a track
    internal func stopTrack(_ track: TrackSettings) {
        trackSequencers[track.trackId]?.stop()
        trackSequencers[track.trackId]?.rewind()
        trackSequencers[track.trackId]?.preroll()
    }
    
    private func playEngineUIEffect() {
        do {
            //Fire up the audio engine
            try audioEngine.start()
        } catch {
            print("Engine not started")
        }
    }
    
    public func pauzeEngineAndStopTracks(setSettings: SetSettings) {
        
        guard isConductorPlayingSubject.value else { return }
        setSettings.tracks.values.forEach {
            envDownTracks($0)
            if $0.noteSource == .midiFile { stopTrack($0) }
            if $0.noteSource == .noteNumbers { stopNoteNumber($0) }
        }
        audioEngine.pause()
        isConductorPlayingSubject.send(false)
    }
}
