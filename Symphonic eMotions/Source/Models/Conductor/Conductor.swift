//
//  Conductor.swift
//  eMotion
//
//  Created by Mihai Fratu on 30.09.2021.
//

import Foundation
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
    private var mixer: Mixer
    //Second mixer is the output of the first mixer's effect chain output
    private var mixerMaster: Mixer
    //Group mixers
    private var groupMixers: [String: Mixer] = [:]
    
    //trackSequencers holds MIDI file information
    //Is the play head in the score
    //Controls speed, loop (length)
    //The playhead can only move in time
    private var trackSequencers: [String: AppleSequencer] = [:]
    //To move the playhead to another part in the score:
    //Copy part to move to current length
    private var trackSequencersMemory: [String: AppleSequencer] = [:]
    //Modifying midi like velocity
    //TODO: Modify note material
    private var trackSequencersCallbackers: [String: MIDICallbackInstrument] = [:]
    
    private var isSequencerPlaying: [String: Bool] = [:]
    
    //Velocities per track to be controlled by intrumentParts
    private var velocities: [String: Double] = [:]
    //Tempo, 1 part for all sequencers. So have only 1 part per instrument set
    //NB Tempo only works for velocity sensitive instruments
    //TODO: Deprecate old tempo
    private var tempo: [String: Double] = [:]
    
    private var currentTempo: Double = 0
    
    //TODO generic var for controlling Synth and Sampler params
    private var soundModuleParam01: [String: Double] = [:]
    private var soundModuleParam02: [String: Double] = [:]
    private var soundModuleVolume: [String: Double] = [:]
    
    //What part of the MIDI clip are we playing.
    private var triggerCurrentMIDIpart: [String: Int] = [:]
    private var globalCurrentMIDIclip: [String: Int] = [:]
    private var currentMIDIclip: [String: Int] = [:]
    //Index = level, value is midiclip
//    private var levelToMidiClip: [String: Int] = [:]
    
    
    //Monitor per instrument movement "wave"
    //A track can have just one wave
    //Functions using wave
    //-Trigger Sequencer
    //-Trigger MidiData
    //- Scorewander
    
    private var trackWaveActive: [String: Bool] = [:]
    private var trackWaveStart: [String: Duration] = [:]
    private var trackWavePreviousValue: [String: Double] = [:]
    private var trackWaveStop: [String: Duration] = [:]
    private var trackWaveInCooldown: [String: Bool] = [:]
    
    //Start event at moment in time
    private var scorePartWatingToChange: [String: Double] = [:]
    
    //Holds notes which are used in sequencer replacement.
    //This is the basis of an Arpegiator
    //"note number index (midiData group)" and note number combination
    private var midiDataGroupNoteNumbers: [String: [Int]] = [:]
    private var midiDataGroupIndex: [String: [Int]] = [:]
    
    //Keep track of maxIndex values per track
    private var maxIndexParts: [String: Int] = [:]
    //keep track of delta start times
//    private var deltaStartTimePart: [String: DispatchTime] = [:]
    
    //TODO: Make generic container for samplers and synths
    //Sampler container
    private var trackSamplers: [String: MIDISampler] = [:]
    //Synth container
    private var trackInstruments: [String: Node] = [:]
    
    //Sampler for interface audio
    //TODO: this needs to get plugged into the second mixer next to Mastertrack effects
    private var soundEffectSampler: MIDISampler = MIDISampler(name: "Sound Effects")
    
    //Amplitude enelopes for muting tracks for levels
    //TODO: init of these needs to be at 0 (-90Db)
    private var trackAmpEnvelopes: [String: AmplitudeEnvelope] = [:]
    
    //Feedback in instrumentpart, stored by partId
    //var to smoothen out the raw values from image differece
//    private var previousValueSmooth: [String: Double] = [:]
    
    //Ramp values containers stored per Instrument.Part
    public var rampValues: [String: Double] = [:]
    //Ramp up and Ramp down values from struct and control from editor
    public var rampUp: [String: Double] = [:]
    public var rampDown: [String: Double] = [:]
    public var volume: [String: Double] = [:]
    
    //TODO: add minimum value to interface
    //TODO: add maximimum value to structure (from maximum on reverse calculation can be done)
    
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
    private var set: InstrumentsSet

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
        isSequencerPlaying = [:]
        velocities = [:]
        tempo = [:]
        soundModuleParam01 = [:]
        soundModuleParam02 = [:]
        soundModuleVolume = [:]
        
        triggerCurrentMIDIpart = [:]
        globalCurrentMIDIclip = [:]
        currentMIDIclip = [:]
        
        scorePartWatingToChange = [:]
        
        trackWaveActive = [:]
        trackWaveStart = [:]
        trackWavePreviousValue = [:]
        trackWaveStop = [:]
        trackWaveInCooldown = [:]
        
        midiDataGroupNoteNumbers = [:]
        midiDataGroupIndex = [:]
        
        trackAmpEnvelopes = [:]
//        previousValueSmooth = [:]
        rampValues = [:]
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
            
            //allValues instrument have a group of samplers
            if track.instrumentType == .allValues {
                
                let midiDataGroup = track.midiGroup ?? []
                for (i,_) in midiDataGroup.enumerated() {
                    let samplerId = track.id + String(i)
                    
                    //Stop all running processes
                    if let previousNoteNumbers = midiDataGroupNoteNumbers[samplerId] ?? nil {
                        for noteNumber in previousNoteNumbers {
                            let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
                            trackSamplers[samplerId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
                        }
                    }
                    
                    do {
                        try trackSamplers[samplerId]!.loadEXS24("Sounds/Sampler Instruments/trigger")
                    } catch {
                        print("Error loading EXS: trigger")
                    }
                }
            }
            //The original way
            else{
                
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
                    rampValues[part.id] = 0.0
                    rampUp[part.id] = part.damperTarget.nodeSettings!.rampSpeed ?? -1
                    rampDown[part.id] = part.damperTarget.nodeSettings!.rampSpeedDown ?? -1
                    maxIndexParts[part.id] = 0
//                    deltaStartTimePart[part.id] = DispatchTime.now()
                }
            }
                        
            //Fill ramps for allValue samplers
            if track.instrumentType == .allValues {
                
//                let group = track.parts.first!.damperTarget.midiData!.group
                let group = track.midiGroup ?? []
                for(i,_) in group.enumerated() {
                    
                    let samplerId = track.id + String(i)
                    rampValues[samplerId] = 0.0
                    rampUp[samplerId] = rampUp[track.parts.first!.id]
                    rampDown[samplerId] = rampDown[track.parts.first!.id]
                }
            }
            
            //Tempo defaults to 1 times set BPM
            tempo[track.id] = 1
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
            
            isSequencerPlaying[track.id] = false
            
            soundModuleParam01[track.id] = 0
            soundModuleParam02[track.id] = 0
            soundModuleVolume[track.id] = 0
            
            trackWaveActive[track.id] = false
            trackWaveStart[track.id] = Duration(beats: 0.0)
            trackWaveStop[track.id] = Duration(beats: 0.0)
            
            midiDataGroupNoteNumbers[track.id] = []
            midiDataGroupIndex[track.id] = [0]
            
            triggerCurrentMIDIpart[track.id] = 0
            currentMIDIclip[track.id] = 0
            globalCurrentMIDIclip[track.id] = 0
            
            scorePartWatingToChange[track.id] = 0
            trackWaveInCooldown[track.id] = false
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
            
        //Does this set have "MIDI clips" follow levels
        //I.E. Score Walk by level <- This is timed through score by user movement
//        let levelClipControl = set.levelClipControl ?? false
//        let levelClipControlStartLevel = set.levelClipControlStartLevel ?? 0
            
        //Run over all tracks
        set.tracks.forEach { track in
            
            //For all tracks, move up a clip modulo amount of clips
            if setSettings.tracks[track.trackId]!.trackType == .midiClipLevel && source == "levelChange" {
                
                stopNotesTrackId(for: track.trackId)
                
                levelMidiClipVariation(in: selectedLevel, on: track)
            }
            
            //UN-Mute
            if setSettings.tracks[track.id]!.levels.contains(selectedLevel)
            {
                let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 1)
                trackAmpEnvelopes[track.id]!.scheduleMIDIEvent(event: trackOn)
                unMuteTrack(trackId: track.id)
            }
            //Mute
            else {
                let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
                trackAmpEnvelopes[track.id]!.scheduleMIDIEvent(event: trackOff)
                muteTrack(trackId: track.id)
                
            }
            
            
//            //Don't (un)mute MIDI only instruments
//            if track.instrumentType != .exsSamplerMIDI {
//
//                let thisTrackIsReferenced = isInstrumentPlayedByMIDIonlyInstrument(selectedLevel: selectedLevel, trackId: track.id)
//
//                //UN-Mute
//                if setSettings.tracks[track.id]!.levels.contains(selectedLevel) || thisTrackIsReferenced
//                {
//                    let trackOn = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 127, channel: 0)
//                    trackAmpEnvelopes[track.id]!.scheduleMIDIEvent(event: trackOn)
//                    unMuteTrack(trackId: track.id)
//                }
//                //Mute
//                else {
//                    let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 0)
//                    trackAmpEnvelopes[track.id]!.scheduleMIDIEvent(event: trackOff)
//                    muteTrack(trackId: track.id)
//
//                }
//            }
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
    
    private func isInstrumentPlayedByMIDIonlyInstrument( selectedLevel: Int, trackId: String ) -> Bool {
        
        //if a midi only track is active which points to this instrument then do not mute this track
        //do this by checking if this track ID is referenced by a MIDI only instrument
        var thisTrackIsReferenced = false
        set.tracks.forEach { tr in
            if tr.midiTargetTrackId == trackId {
                if tr.levels.contains(selectedLevel){
                    thisTrackIsReferenced = true
                }
            }
        }
        return thisTrackIsReferenced
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
            
//            if track.startType == .triggerSlaveMaxIndex {
//                //FIXME: Not responding?
//                sequencer.disableLooping()
//            }
//            else{
                sequencer.setLoopInfo(duration, loopCount: 0)
                sequencer.enableLooping()
//            }
            
            //loop means, we have an actual instrument, not a sequencer loaded for copy reference
            if length == "loop" {
                
                switch track.instrumentType {
                case .allValues:
                    
                    let midiDataGroup = track.midiGroup ?? []
                    
                    groupMixers[track.id] = Mixer()
                    
                    //Create EXS samplers per notenumber in midiDataGroup
                    for (i,_) in midiDataGroup.enumerated() {
                        
                        let samplerId = track.id + String(i)
                        
                        trackSamplers[samplerId] = createExsGroup(for: track, and: sequencer, samplerId: samplerId)
                        
                        sequencer.setGlobalMIDIOutput(trackSamplers[samplerId]!.midiIn)
                    }
                    
                case .exsSampler:
                    
                    //Create EXS sampler
                    trackSamplers[track.id] = createExsSampler(for: track, and: sequencer)
                    
                    //Create seperate isVelocity func
                    let isVelocitySensitive = isVelocitySensitive(for: track)
                    
                    
                    if isVelocitySensitive {
                            
                        let tempoRange = tempoRange(for: track)
                        
                        //Create MIDI callback instrument
                        //track is used for just the ID
                        trackSequencersCallbackers[track.id] = callBackInstrument(
                            for: track.id,
                               controlling: trackSamplers[track.id]!,
                               on: midiChannels[track.id]!,
                               within: tempoRange)
                        
                        sequencer.setGlobalMIDIOutput(trackSequencersCallbackers[track.id]!.midiIn)
                    }
                    else{
                        sequencer.setGlobalMIDIOutput(trackSamplers[track.id]!.midiIn)
                    }
                
                    //Reference MIDI sequencers do not need the actual instruments
                case .exsSamplerMIDI:
                    
                    //Just the call back, sending track must have velocity?
                    //Create seperate isVelocity func
                    if isVelocitySensitive(for: track) {
                        
                        let tempoRange = tempoRange(for: track)
                        
                        //Create MIDI callback instrument
                        //Here the sampler is an excisting sampler from another track
                        trackSequencersCallbackers[track.id] = callBackInstrument(
                            for: track.id,
                               controlling: trackSamplers[track.midiTargetTrackId!]!,
                               on: midiChannels[track.midiTargetTrackId!]!,
                               within: tempoRange)
                        
                        sequencer.setGlobalMIDIOutput(trackSequencersCallbackers[track.id]!.midiIn)
                    }
                    else{
                        sequencer.setGlobalMIDIOutput(trackSamplers[track.midiTargetTrackId!]!.midiIn)
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
    
    //MARK: EXS Sampler
    private func createExsSampler(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer) -> MIDISampler? {
            
            // Use the 1st exs file defined.
            guard let exsFile = track.exsFiles?.first else { // TODO: Why is this an array?!?
                print("No EXS file for track id: \(track.id)")
                return nil
            }
            
            let sampler = MIDISampler(name: track.instrumentName)
            sampler.amplitude = track.volume
            
            let chainEffects: Node = chainEffects(for: track, startingNode: sampler)
            let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
            
            mixer.addInput(ampEnv)
            
            do {
                
                try sampler.loadEXS24("Sounds/Sampler Instruments/\(exsFile.fileName)")
            } catch {
                print("Error loading EXS: \(exsFile.fileName)")
            }
            
            return sampler
        }
    
    private func createExsGroup(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer,
        samplerId: String
    ) -> MIDISampler?{
        // Use the 1st exs file defined.
        guard let exsFile = track.exsFiles?.first else { // TODO: Why is this an array?!?
            print("No EXS file for samplerId: \(samplerId)")
            return nil
        }
        
        let sampler = MIDISampler(name: track.instrumentName + samplerId)
        
        print( "createExsGroup \(track.instrumentName) \(samplerId) amplitude  \(track.volume)" )
        sampler.amplitude = track.volume
        
        groupMixers[track.id]!.addInput(sampler)
        
        let chainEffects: Node = chainEffects(for: track, startingNode: groupMixers[track.id]!)
        let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
        
        mixer.addInput(ampEnv)
        
        do {
            
            try sampler.loadEXS24("Sounds/Sampler Instruments/\(exsFile.fileName)")
        } catch {
            print("Error loading EXS: \(exsFile.fileName)")
        }
        
        return sampler
    }
    
    //MARK: Audio buffer sampler
    private func createAudioBufferSampler(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer,
        currentSetLevel: Double) -> MIDISampler? {
        
        // Use the 1st audio file defined.
        guard let audioFile = track.audioFiles?.first else { // TODO: Why is this an array?!?
            print("No audio file for track id: \(track.id)")
            return nil
        }
        
        // Use the 1st audio file defined.
        guard let midiFile = track.midiFiles?.first else { // TODO: Why is this an array?!?
            print("No midi file for track id: \(track.id)")
            return nil
        }
        
        
        guard let audioFileURL = Bundle.main.url(forResource: audioFile.fileName, withExtension: audioFile.fileExtension, subdirectory: "Samples/\(set.filesPath)") else {
            print("Audio file not found at path Samples/\(set.filesPath)/\(audioFile.fileName).\(audioFile.fileExtension) for track id: \(track.id)")
            return nil
        }
        var avAudioFiles = [AVAudioFile]()
        
        let sampler = MIDISampler(name: track.instrumentName)
        sampler.amplitude = track.volume
        
        let loopLength = midiFile.loopLength.first
        sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: loopLength ?? 64))
        
        //tempoTrack is optional instrument track without sound (grey instrument)
        //MARK: Tempo Track
        if track.id == "tempoTrack"  {
            
            let velocitySLider = 0
            var tempoLow = set.bpm
            var tempoHigh = set.bpm
            if track.parts.count > 0 {
                for part in track.parts {
                    
                    if  part.damperTarget.parameter == "tempo" &&
                            part.damperTarget.nodeSettings?.tempoLow != nil &&
                            part.damperTarget.nodeSettings?.tempoHigh != nil {
                        tempoLow = part.damperTarget.nodeSettings?.tempoLow ?? set.bpm
                        tempoHigh = part.damperTarget.nodeSettings?.tempoHigh ?? set.bpm
                    }
                }
            }
            
            for i in 0..<Int(loopLength ?? 4) {
                
                var velocity = 80 * velocitySLider
                if i == 0 { velocity = 120 * velocitySLider}
                
                sequencer.tracks.first?.add(
                    noteNumber: audioFile.midiNote,
                    velocity: MIDIVelocity(velocity),
                    position: Duration(beats: Double(i)),
                    duration: Duration(beats: 0.05)
                )
                
                sequencer.tracks.first?.add(
                    noteNumber: audioFile.midiNote,
                    velocity: MIDIVelocity(40 * velocitySLider),
                    position: Duration(beats: (Double(i) + 0.25)),
                    duration: Duration(beats: 0.05)
                )
                
                sequencer.tracks.first?.add(
                    noteNumber: audioFile.midiNote,
                    velocity: MIDIVelocity(60 * velocitySLider),
                    position: Duration(beats: (Double(i) + 0.5)),
                    duration: Duration(beats: 0.05)
                )
                
                sequencer.tracks.first?.add(
                    noteNumber: audioFile.midiNote,
                    velocity: MIDIVelocity(40 * velocitySLider),
                    position: Duration(beats: (Double(i) + 0.75)),
                    duration: Duration(beats: 0.05)
                )
            }
            
            let callbacker = MIDICallbackInstrument { [self] status, note, velocity in
                guard let midiStatus = MIDIStatusType.from(byte: status) else {
                    return
                }
                
                if midiStatus == .noteOn {
                    
                    //TODO midiStatus == .noteOn does not pass chords, just single notes
                    //let newVelocity = UInt8( Double(velocity) * velocities[track.id]! )
                    sampler.play(noteNumber: note, velocity: velocity, channel: 1)
                    
                }
                else if midiStatus == .noteOff {
                    
                    /*
                     createAudioBufferSampler, tempo param controls all sequencers speed
                     */
                    if track.levels.contains(Int(currentSetLevel)) {
                        let tempoRange = (set.bpm + tempoHigh) - (set.bpm + tempoLow)
                        let playedTempo: Double = tempoRange * tempo[track.id]! + (set.bpm + tempoLow )
                        
                        //All sequences get this tempo
                        for trackId in trackSequencers.keys {
                            if trackSequencers[trackId] != nil {
                                trackSequencers[trackId]!.setTempo(playedTempo)
                            }
                        }
                    }
                    
                    sampler.stop(noteNumber: note, channel: 1)
                }
            }
            sequencer.setGlobalMIDIOutput(callbacker.midiIn)
            
        }
        
        else{
            sequencer.tracks.first?.add(
                noteNumber: audioFile.midiNote,
                velocity: 120,
                position: Duration(beats: 0),
                duration: Duration(beats: midiFile.loopLength.first ?? 4)
            )
            
            sequencer.setGlobalMIDIOutput(sampler.midiIn)
        }
        
        let chainEffects: Node = chainEffects(for: track, startingNode: sampler)
        let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
        
        mixer.addInput(ampEnv)
        
        do {
            //            try sampler.loadAudioFile(try AVAudioFile(forReading: audioFileURL))
            try avAudioFiles.append(AVAudioFile(forReading: audioFileURL))
            try sampler.loadAudioFiles(avAudioFiles)
            
        } catch {
            print("Error audioFileURL: \(audioFileURL)")
        }
        
        return sampler
    }
    // MARK: Synths
    private func createPulseWidthSynth(
        for track: InstrumentsSet.Track,
        and sequencer: AppleSequencer) -> Node? {
        
        var isPlaying: Bool = false
        let osc = PWMOscillator()
        //osc.amplitude = 1
        
        //Waarde vervangen met functie call duratie * sinus voor instant LFO
        //TODO make pulsewidth variable
        let pulseWidth: AUValue = 0.5
        osc.pulseWidth = pulseWidth
        
        //      case .phaseSynth:
        //      osc = PhaseDistortionOscillator()
        //PhaseDistortionOscillator
        
        let tb303ftl = RolandTB303Filter(osc)
        
        let env = AmplitudeEnvelope(tb303ftl)
        
        let compressor = Compressor(env)
            
        //Waarde met aanstuurbare functie vervangen
        let freqRampDuration: AUValue = 0.025
        
        //Sequencer to callback to play sampler
        let callbacker = MIDICallbackInstrument { [self] status, note, velocity in
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            if midiStatus == .noteOn {
                
                if !isPlaying {
                    osc.start()
                    //TODO, before switch set, set this to osc.stop()
                    isPlaying = true
                }
                
                var newVelocity = UInt8(max(Double(Int(velocity)) * velocities[track.id]!,0))
                if newVelocity > 127 { newVelocity = 127 }
                osc.amplitude = AUValue(velocities[track.id]!)
                
                //TODO midiStatus == .noteOn does not pass chords, just single notes
                //osc.frequency = note.midiNoteToFrequency()
                
                env.attackDuration = 0.01
                env.decayDuration = 0.05
                env.sustainLevel = 0
                env.releaseDuration = 0.005
                
                
                let noteOn = MIDIEvent(noteOn: note, velocity: newVelocity, channel: 1)
                env.scheduleMIDIEvent(event: noteOn)
                
                osc.$frequency.ramp(to: note.midiNoteToFrequency(), duration: freqRampDuration)
                
                let tb303ftlCutOff: Double = 500 - soundModuleParam01[track.id]! * 50
                
                tb303ftl.$cutoffFrequency.ramp(to: AUValue(tb303ftlCutOff), duration: 0.01)
                
                let resonance = soundModuleParam01[track.id] ?? 0 * 0.8 + 0.5
                
                tb303ftl.$resonance.ramp(to: AUValue(resonance), duration: 1)
                
                compressor.attackTime = 0.001
                compressor.releaseTime = 0.05
                compressor.threshold = -4
                let volume = soundModuleVolume[track.id] ?? 0
                
                compressor.$masterGain.value = AUValue(volume)
                
            }
            else if midiStatus == .noteOff {
                
                let noteOff = MIDIEvent(noteOn: note, velocity: 0, channel: 1)
                env.scheduleMIDIEvent(event: noteOff)
            }
        }
        sequencer.setGlobalMIDIOutput(callbacker.midiIn)
        
        
            let chainEffects: Node = chainEffects(for: track, startingNode: compressor)
            let ampEnv: Node = setTrackAmpEnvelope(trackId: track.id, startingNode: chainEffects)
            
            mixer.addInput(ampEnv)
        
        return env as Node
    }
    
    private func createPhaseSynth(
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
        
        var isTempoController = false
        var tempoLow = set.bpm
        var tempoHigh = set.bpm
        if track.parts.count > 0 {
            for part in track.parts {
                if part.damperTarget.parameter == "tempo" &&
                    part.damperTarget.nodeSettings?.tempoLow != nil &&
                    part.damperTarget.nodeSettings?.tempoHigh != nil{
                    isTempoController = true
                    tempoLow = part.damperTarget.nodeSettings?.tempoLow ?? set.bpm
                    tempoHigh = part.damperTarget.nodeSettings?.tempoHigh ?? set.bpm
                }
            }
        }
        
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
                
                /*
                 createPhaseSynth, soundModule param controls sequencer speed
                 */
                if isTempoController {
                    
                    //tempoHigh is relative above set.bpm
                    //tempoHigh is relative below set.bpm
                    let tempoRange = (set.bpm + tempoHigh) - (set.bpm + tempoLow)
                    let playedTempo: Double = tempoRange * tempo[track.id]! + (set.bpm + tempoLow )
                    
                    //All sequences get this tempo
                    for trackId in trackSequencers.keys {
                        if trackSequencers[trackId] != nil {
                            trackSequencers[trackId]!.setTempo(playedTempo)
                        }
                    }
                }
                
                //TODO add trackNotesOn tracker
                
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
    
    private func tempoRange(
        for track: InstrumentsSet.Track) -> (Double,Double) {
            
            var tempoLow = set.bpm
            var tempoHigh = set.bpm
            if track.parts.count > 0 {
                for part in track.parts {
                    if part.damperTarget.parameter == "tempo" &&
                        part.damperTarget.nodeSettings?.tempoLow != nil &&
                        part.damperTarget.nodeSettings?.tempoHigh != nil{
                        
                        tempoLow = part.damperTarget.nodeSettings?.tempoLow ?? set.bpm
                        tempoHigh = part.damperTarget.nodeSettings?.tempoHigh ?? set.bpm
                    }
                }
            }
            return (tempoLow,tempoHigh)
        }
    
    private func collectMidiChannels() -> [String: Int] {
        
        var midiTargetChannels: [String: Int] = [:]
        var i: Int = 1
        set.tracks.forEach { track in
            if track.instrumentType == .allValues {
                let midiDataGroup = track.midiGroup ?? []
                for (j,_) in midiDataGroup.enumerated() {
                    let samplerId = track.id + String(j)
                    midiTargetChannels[samplerId] = i
                    i += 1
                }
            }
            else{
                midiTargetChannels[track.id] = i
                i += 1
            }
        }
        return midiTargetChannels
    }
    
    
    //MARK: Callback Instrument
    private func callBackInstrument(
        for trackId: String,
        controlling sampler: MIDISampler,
        on midiChannel: Int,
        within tempoRange: (Double,Double)) -> MIDICallbackInstrument {
                        
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
                    
                    if tempoRange.0 != tempoRange.1 {
                        //tempoHigh is relative above set.bpm
                        //tempoLow is relative below set.bpm, probably negative
                        let tempoRangeOffset = (set.bpm + tempoRange.1) - (set.bpm + tempoRange.0)
                        let playedTempo: Double = tempoRangeOffset * tempo[trackId]! + (set.bpm + tempoRange.0 )
                        
                        //All sequences get this tempo
                        for allTrckId in trackSequencers.keys {
                            if trackSequencers[allTrckId] != nil {
                                trackSequencers[allTrckId]!.setTempo(playedTempo)
                            }
                        }
                    }
                }
                else if midiStatus == .noteOff {
                    
                    sampler.stop(noteNumber: note, channel: MIDIChannel(midiChannel))
                }
            }
            return midiCallBackInstrument
        }
    
    
    //MARK: Chain effects per track
    private func chainEffects(
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
    private func setTrackAmpEnvelope(trackId: String, startingNode: Node) -> Node{
        
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
    
    // MARK: valuesDidChange
    public func valuesDidChange(
        //Values for movement calculations
        values: [[AreaValues]],
        //Dynamic area's of interest
        setSettings: SetSettings,
        //Is track present in current level
        currentSetLevel: Double,
        //Do we want to show this part in part feedback visualisation
        partFeedbackTrackID: String,
        partFeedbackPartID: String
    ) -> Double {
        
        var localCurrentSetLevel: Double = currentSetLevel
        
        let value: Double = values.flatMap { $0 }
            .map { $0.average }
            .reduce(0, +) / Double(values.flatMap { $0 }.count)
        
        //New level increment
        localCurrentSetLevel = getAndOrIncreaseCurrentSetLevel(
            levelSpeed: setSettings.levelSpeed,
            currentSetLevel: currentSetLevel,
            value: value
        )
        var trackNr: Int = 0
        var partNr: Int = 0
        
        //Loop through all tracks per value
        set.tracks.forEach { track in
            //Reset part per track
            partNr = 0
            
            //If muted return
            if track.muted != nil && track.muted == true {
                return
            }
            //No parts return
            if track.parts.count == 0 {
                return
            }
            
            /*
            MARK: New allValues group based on first part

            - send values: [[AreaValues]] to array of sound players
            - Not to effects because of single output sampler

            Not yet compatible with levelClipControl, instrumentControlsLevel

            // Connect: midiDataGroupNoteNumbers
            // Connect: midiDataGroupIndex

            */
            
            if track.instrumentType == .allValues {
                
                let part = track.parts.first!
                
                let valuesMapped = setSettings.tracks[track.trackId]!.parts[part.id]!.indexes(rows: setSettings.gridRows, columns: setSettings.gridColumns).map {
                    values[$0.row][$0.column].scaledValue
                }
                
                guard !valuesMapped.isEmpty else { return }
                
                for (i, letValue) in valuesMapped.enumerated() {
                    
                    let samplerId = part.damperTarget.trackId + String(i)
                    
                    var value = valueDamper(dampMode: part.damperTarget.dampMode!, value: letValue)
                    value = valueRamper(value: value, rampId: samplerId)
                    
                    forwardInstrumment(value: value, on: samplerId, for: "samplerCC9")
                }
                
            }
            else {
                /*
                 MARK: Original multi part system
                 */
                
                //Loop through all parts per track per value
                track.parts.forEach { part in
                    
                    let valuesMapped = setSettings.tracks[track.trackId]!.parts[part.id]!.indexes(
                        rows: setSettings.gridRows,
                        columns: setSettings.gridColumns).map {
                            values[$0.row][$0.column].scaledValue
                        }
                    guard !valuesMapped.isEmpty else { return }
                    
                    //Find highest value (maximum) with it's index
                    let maxIndexTupple = vDSP.indexOfMaximum(valuesMapped)
                    
//                    let boostFactor = setSettings.tracks[track.trackId]!.parts[part.id]?.areaOfIntersetBoostFactor
                    
                    //Have a var for MaxIndex to number of MidiClips range
                    let maxIndexraw = Int(maxIndexTupple.0)
                    var maxIndexMidiClips = maxIndexraw
                    
                    //MaxMapped (highest value found in all of AreaOfInterest) value to work with
                    var value = maxIndexTupple.1
                    if value.isNaN {
                        value = 0
                    }
                    
                    //MARK: index to midi clip conversion
                    //Change order of indeces for mapping with events
                    if setSettings.tracks[track.trackId]!.trackType == .midiClipPosition && partNr == 0 {
                        
                        let mapMaxIndex = setSettings.tracks[track.trackId]!.loopsToGridMapped
                        
                        maxIndexMidiClips = mapMaxIndex[maxIndexMidiClips]
                        forwardMaxIndex(
                            for: part.damperTarget,
                            maxIndex: maxIndexMidiClips
                        )
                    }
                    
                    //Ad damping curves
                    value = valueDamper(dampMode: part.damperTarget.dampMode!, value: value)
                    //Ad ramps from interface!
                    value = valueRamper(value: value, rampId: part.id)
                    
                    //Forward to target
                    forward(
                        value: value,
                        for: part.damperTarget,
                        currentSetLevel: localCurrentSetLevel
                    )
                    
                    if setSettings.defaultSkin == .spriteKit {
                        forwardSpriteKit(
                            trackNr: trackNr,
                            partNr: partNr,
                            ramped: value,
                            areaOfInterest: (setSettings.tracks[track.id]?.parts[part.id]!.areaOfInterest)!,
                            maxIndexRaw: maxIndexraw,
                            maxIndex: maxIndexMidiClips
                        )
                    }
                    else if setSettings.defaultSkin == .swiftUI {
                        //Check part feedback interface state for part feedback visualisation
                        if partFeedbackTrackID == track.id && partFeedbackPartID == part.id {
                            forwardPartFeedback(
                                ramped: value
                            )
                        }
                    }
                    
                    partNr += 1
                }
            }
            
            trackNr += 1
        }
        
        return localCurrentSetLevel
    }
    
    private func valueDamper( dampMode: InstrumentsSet.Track.Part.DamperTarget.DampMode, value: Double) -> Double {
        
        var valueRamped: Double = value
        
        if dampMode == .easeInCircular {
            valueRamped = EaseInCircularDamper().damp(value: valueRamped)
        }
        else if dampMode == .easeInCubic {
            valueRamped = EaseInCubicDamper().damp(value: valueRamped)
        }
        else if dampMode == .easeOutCubic {
            valueRamped = EaseOutCubicDamper().damp(value: valueRamped)
            //Remove unwanted offset
            valueRamped = valueRamped - 0.25
            valueRamped = valueRamped * 1.25
        }
        else if dampMode == .easeInOutCubic {
            valueRamped = EaseInOutCubicDamper().damp(value: valueRamped)
            //Add missing top values
            valueRamped = valueRamped * 1.25
        }
        
        return valueRamped
    }
    
    private func valueRamper(value: Double, rampId: String) -> Double {
        
        var valueRamped: Double = value
        
        //We detect a value higher compared to previous one, we increase
        if valueRamped > rampValues[rampId]! {
            valueRamped = min(rampValues[rampId]! + valueRamped * self.rampUp[rampId]!, 0.9999999)
        }
        //Otherwise we need to go back to 0
        else{
            valueRamped = max(rampValues[rampId]! - (1 - valueRamped) * self.rampDown[rampId]!, 0)
        }
        
        //Memmber berries
        rampValues[rampId] = valueRamped
        
        return valueRamped
    }
    
    public func setSamplerIdRamp(
        rampType: String,
        currentTrackID: String,
        value: Double
    ) {
        
        guard let track = set.track(for: currentTrackID) else { return }
        if track.instrumentType == .allValues {
            
            let group = track.midiGroup ?? []
            for (i,_) in group.enumerated() {
                let samplerId = track.id + String(i)
                if rampType == "rampUp" {
                    rampUp[samplerId] = value
                }
                else if rampType == "rampDown" {
                    rampDown[samplerId] = value
                }
            }
        }
    }
    
    
    //MARK: Forwarders
    //Forward Part Feedback
    public func forwardPartFeedback( ramped: Double ) -> Void {
        forwardRampedPartFeedback.send(ramped)
    }
    
//    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
//        return (max + min) - number
//    }
    
    public func forwardSpriteKit(
        trackNr: Int,
        partNr: Int,
        ramped: Double,
        areaOfInterest: [Int],
        maxIndexRaw: Int,
        maxIndex: Int
    ) -> Void {
        
//        let allCells = areaOfInterest.filter { int in
//            return int == 1
//        }
        //Reverse maxIndexes for inverted Y axis in SpriteKit
//        let reversed = reverseNumber(number: maxIndexRaw, min: 0, max: allCells.count - 1)
        
        if trackNr == 0 {
            if partNr == 0 {
                spriteKitParts0a.send((maxIndexRaw,maxIndex,ramped))
            }
            else if partNr == 1 {
                spriteKitParts0b.send((maxIndexRaw,maxIndex,ramped))
            }
        }
        else if trackNr == 1 {
            if partNr == 0 {
                spriteKitParts1a.send((maxIndexRaw,maxIndex,ramped))
            }
            else if partNr == 1 {
                spriteKitParts1b.send((maxIndexRaw,maxIndex,ramped))
            }
        }
        else if trackNr == 2 {
            if partNr == 0 {
                spriteKitParts2a.send((maxIndexRaw,maxIndex,ramped))
            }
            else if partNr == 1 {
                spriteKitParts2b.send((maxIndexRaw,maxIndex,ramped))
            }
        }
        else if trackNr == 3 {
            if partNr == 0 {
                spriteKitParts3a.send((maxIndexRaw,maxIndex,ramped))
            }
            else if partNr == 1 {
                spriteKitParts3b.send((maxIndexRaw,maxIndex,ramped))
            }
        }
    }
    
    //Forward damper data
    private func forward(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        currentSetLevel: Double
    ) {
        switch damperTarget.nodeType {
        case .instrument:
            forwardInstrumment(value: value, on: damperTarget.trackId, for: damperTarget.parameter)
        case .sequencer:
            forwardSequencer(
                value: value,
                for: damperTarget,
                currentSetLevel: currentSetLevel)
        case .effect:
            forwardEffect(value: value, for: damperTarget)
        case .master:
            return
        }
    }
    
    public func forwardInstrumment(value: Double, on trackId: String, for parameter: String) {
        switch parameter {
        case "volume":
            
            for track in set.tracks {
                if track.id == trackId {
                    if track.instrumentType == .exsSampler {
                        trackSamplers[trackId]?.volume = AUValue(value)
                    }
                    else {
                        soundModuleVolume[trackId] = value
                    }
                }
            }
            
        case "amplitude":
            
            for track in set.tracks {
                if track.id == trackId {
                    let ranged = RangeConverter.valueToRange(range: [-90,12], value: value)
                    if track.instrumentType == .exsSampler {
                        trackSamplers[trackId]?.amplitude = AUValue(ranged)
                    }
                    else {
                        let ranged = RangeConverter.valueToRange(range: [-40,40], value: value)
                        soundModuleVolume[trackId] = ranged
                    }
                }
            }
            
            
        case "samplerCC9":
            trackSamplers[trackId]?.midiCC(UInt8(9), value: UInt8(value * 127), channel: UInt8(1))
        default:
            print("Instrument damperTarget.parameter Not mapped: \(parameter)")
        }
    }
    
    private func forwardMaxIndex(
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        maxIndex: Int
//        ,
//        isNewIndex: Bool
    ) {
    
        //Low level midi data control based on index of activity
//        if maxIndex != -1 && isNewIndex {
            
            guard let track = set.track(for: damperTarget.trackId) else { return }
            let maxIndexPart = maxIndex % track.midiFiles!.first!.loopLength.count
            //Copy MIDI part based on max movement cell index
            switchTrackMidiPart(track, maxIndexPart)
//        }
    }
    
    private func forwardSequencer(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        currentSetLevel: Double
    ) {
            
            //Parameter controllers
            switch damperTarget.parameter {
            
            case "velocity":
                
                guard let track = set.track(for: damperTarget.trackId) else { return }
                //Check wether track.id is in current level
                
                if track.levels.contains(Int(currentSetLevel)) {
                    velocities[track.id] = value
                }
                else { velocities[track.id] = 0 }
            case "tempo":
                guard let track = set.track(for: damperTarget.trackId) else { return }
                tempo[track.id] = value
                
            case "soundModuleParam01":
                guard let track = set.track(for: damperTarget.trackId) else { return }
                soundModuleParam01[track.id] = value
            case "soundModuleParam02":
                guard let track = set.track(for: damperTarget.trackId) else { return }
                soundModuleParam02[track.id] = value
                
            case "trigger":
                
                triggerStartStopGroup(value: value, for: damperTarget)
            
            case "triggerMidiDataSlaves":
                
                triggerMidiDataSlaves(value: value, for: damperTarget)
                
            case "midiData":
                
                triggerMidiData(value: value, for: damperTarget)
                
            case "playMidiData":
                
                playMidiData(with: damperTarget)
            
//                case .rampToMIDIclip:
//
//                    scoreWandererRampToMIDIclip(
//                        value: value,
//                        for: damperTarget,
//                        clipLengths,
//                        midiClipVariations
//                    )
//
//                case .valueToMIDIclip:
//
//                    scoreWandererValueToMIDIclip(
//                        value: value,
//                        for: damperTarget,
//                        clipLengths,
//                        midiClipVariations
//                    )
//                }
                
            default:
                print("Sequencer damperTarget.parameter Not mapped: \(damperTarget.parameter)")
        }
    }
    
//    private func isPartDeltaTimeRunning(partId: String, partDeltaTime: Int) -> Bool {
//
//        var isRunning = false
//
//        if deltaStartTimePart[partId]! + .milliseconds(partDeltaTime) > DispatchTime.now() {
//            isRunning = true
//        }
//
//        return isRunning
//    }
    
    private func valueIndexChanged(maxIndex: Int, trackId: String) -> Bool{
        if maxIndexParts[trackId] != maxIndex {
            maxIndexParts[trackId] = maxIndex
            return true
        }
        return false
    }
    
    private func forwardEffect(value: Double, for damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        
        guard let track = set.track(for: damperTarget.trackId) else { return }
        
        guard let effectType = InstrumentsSet.Track.Effect.EffectType(rawValue: damperTarget.nodeName) else { return }
        
        guard let effect = track.effect(for: effectType) else { return }
        
        effect.apply(value: value, with: damperTarget)
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
    private func getAndOrIncreaseCurrentSetLevel(
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
    
    //MARK: MidiData
    //TODO: Hier ben ik 13 april 2023
    //Idee maak het wachten op trigger window zichtbaar, balletje dat je wegslaat
    //vertrek snelheid is velocity van triggermoment
    private func triggerMidiData(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget ){
            
            //The mimimal amount of movement before looking up a trigger
            guard let minimalLevel = damperTarget.nodeSettings?.minimalLevel else { return }
            
            //Is there a wave present?
            if trackWaveActive[damperTarget.trackId] ?? false {
                
                //End wave, stop note
                //Keeps possibility multiple note ons
                if value < (minimalLevel - (minimalLevel/2)) {
                    
                    //The trigger wave is over
                    trackWaveActive[damperTarget.trackId] = false
                    
                    //First in first out
                    guard let noteNumber = midiDataGroupNoteNumbers[damperTarget.trackId]?.first else { return }
                    midiDataNoteOff(noteNumber: noteNumber, samplerId: damperTarget.trackId)
                }
            }
            //There's no wave present
            else {
                
                //Is there enough movement to start wave?
                if value > minimalLevel {
                    
                    trackWaveActive[damperTarget.trackId] = true
                    
                    let group = damperTarget.midiData!.group
                    
                    //TODO: Creative ways to disclose
                    //Random
                    //let noteNumberIndex = Int.random(in: 0...(group.count-1))
                    //More movement is higher index
                    //
                    
                    let noteNumberIndex = ((midiDataGroupIndex[damperTarget.trackId]?.last)! + 1 ) % group.count
                    let noteNumber = group[noteNumberIndex]
                    let velocity = 127
                    
                    midiDataNoteOn(noteNumber: noteNumber, velocity: velocity, samplerId: damperTarget.trackId, groupIndex: noteNumberIndex)
                }
            }
            //Store value for comparising within this function
            trackWavePreviousValue[damperTarget.trackId] = value
        }
    
    private func triggerMidiDataSlaves (
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget ){
            
            //The mimimal amount of movement before looking up a trigger
            guard let minimalLevel = damperTarget.nodeSettings?.minimalLevel else { return }
            
            //Is there a wave present?
            if trackWaveActive[damperTarget.trackId] ?? false {
                
                //End wave, stop note
                //Keeps possabilety multiple note ons
                if value < (minimalLevel - (minimalLevel/2)) {
                    
                    //The trigger wave is over
                    trackWaveActive[damperTarget.trackId] = false
                    
                    //Find Self and Slaves. midiData object needs to be in the FIRST instrument part
                    let startTypes: [InstrumentsSet.Track.StartType] = [.triggerMidiDataSlaves, .midiDataSlave]
                    set.tracks.filter { startTypes.contains($0.startType) }.forEach {
                        //First in first out
                        guard let noteNumber = midiDataGroupNoteNumbers[$0.trackId]?.first else { return }
                        midiDataNoteOff(noteNumber: noteNumber, samplerId: $0.trackId)
                    }
                }
            }
            //There's no wave present
            else {
                
                //Is there enough movement to start wave?
                if value > minimalLevel {
                    
                    trackWaveActive[damperTarget.trackId] = true
                    
                    //Find Self and Slaves. midiData object needs to be in the FIRST instrument part
                    let startTypes: [InstrumentsSet.Track.StartType] = [.triggerMidiDataSlaves, .midiDataSlave]
                    set.tracks.filter { startTypes.contains($0.startType) }.forEach {
                        
                        let group = $0.parts.first!.damperTarget.midiData!.group
                        let noteNumberIndex = ((midiDataGroupIndex[$0.trackId]?.last)! + 1 ) % group.count
                        let noteNumber = group[noteNumberIndex]
                        let velocity = 127
                        
                        midiDataNoteOn(noteNumber: noteNumber, velocity: velocity, samplerId: $0.trackId, groupIndex: noteNumberIndex)
                    }
                }
            }
            //Store value for comparising within this function
            trackWavePreviousValue[damperTarget.trackId] = value
        }
    
    private func midiDataNoteOn( noteNumber: Int, velocity: Int, samplerId: String, groupIndex: Int) {
        
        let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(velocity), channel: 1)
        trackSamplers[samplerId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
        
        //Register we are playing
        midiDataGroupNoteNumbers[samplerId]?.append(noteNumber)
        midiDataGroupIndex[samplerId]?.append(groupIndex)
    }
    
    private func midiDataNoteOff( noteNumber: Int, samplerId: String) {
        
        let noteOff = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 0, channel: 1)
        trackSamplers[samplerId]!.scheduleMIDIEvent(event: noteOff, offset: UInt64(0))
        
        //Un register note
        midiDataGroupNoteNumbers[samplerId]?.removeFirst()
        midiDataGroupIndex[samplerId]?.removeFirst()
    }
    
    private func playMidiData(
        with damperTarget: InstrumentsSet.Track.Part.DamperTarget ){
            
            //Is current trac playing?
            let trackWaveActiveUnwrap = trackWaveActive[damperTarget.trackId] ?? false
            
            if !trackWaveActiveUnwrap {
                
                trackWaveActive[damperTarget.trackId] = true
                
                let noteNumber = damperTarget.midiData!.group.first ?? 0
                midiDataGroupNoteNumbers[damperTarget.trackId]?.append(noteNumber)
                let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 120, channel: 1)
                trackSamplers[damperTarget.trackId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
            }
        }
    
    private func playMidiDataAllValues(
        with track: InstrumentsSet.Track ){
            
            //Is current trac playing?
            let trackWaveActiveUnwrap = trackWaveActive[track.id] ?? false
            
            if !trackWaveActiveUnwrap {
                
                let damperTarget = track.parts.first!.damperTarget
                trackWaveActive[damperTarget.trackId] = true
                
                let group = damperTarget.midiData!.group
                for (i,noteNumber) in group.enumerated(){
                    let samplerId = track.id + String(i)
                    midiDataGroupNoteNumbers[samplerId]?.append(noteNumber)
                    let noteOn = MIDIEvent(noteOn: MIDINoteNumber(noteNumber), velocity: 120, channel: 1)
                    trackSamplers[samplerId]!.scheduleMIDIEvent(event: noteOn, offset: UInt64(0))
                }
            }
        }
    
    //MARK: Triggers
    private func triggerStartStopGroup(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget
    ){
        
        //The mimimal amount of movement before looking up a trigger
        guard let minimalLevel = damperTarget.nodeSettings?.minimalLevel else { return }
        
        //We need the position to hold "fire clip" until next beat
        let currentMoment = trackSequencers["trigger"]?.currentPosition.beats
        
        //scorePartWatingToChange caries the moment the trigger occured
        if scorePartWatingToChange[damperTarget.trackId]! != 0.0 {
           
            //The moment the triggers needs to be minus the current moment
            //If it's not been yet but difference is smaller than 0.05 go trigger by starting wave
            //If the moment is in the past (< currentMoment) also go trigger.
            if scorePartWatingToChange[damperTarget.trackId]! <= currentMoment! {
                
                //Start wave!
                //We need to look up all trigger tracks and start them
                let startTypes: [InstrumentsSet.Track.StartType] = [.triggerSlave,.triggerSlaveMaxIndex]
                set.tracks.filter { startTypes.contains($0.startType) }.forEach {
                    playTrack($0)
                }
                
                //Track wave globaly
                trackWaveActive[damperTarget.trackId] = true
                //Reset waiting for fire
                scorePartWatingToChange[damperTarget.trackId]! = 0.0
            }
        }
        //No clip is waiting for triggering
        else{
            
            //Is there a wave present?
            if trackWaveActive[damperTarget.trackId] ?? false {
                
                //Stop wave if current value is lower compared to previous frame minus minimalLevel
                //OR value is below minimal level
                if value < (trackWavePreviousValue[damperTarget.trackId] ?? 0) - minimalLevel
                    || value < minimalLevel {
                    
                    
                    let startTypes: [InstrumentsSet.Track.StartType] = [.triggerSlave,.triggerSlaveMaxIndex]
                    set.tracks.filter { startTypes.contains($0.startType) }.forEach {
                        stopTrack($0)
                    }
                    
                    //The trigger wave is over
                    trackWaveActive[damperTarget.trackId] = false
                }
            }
            //There's no wave present
            else {
                
                //Is there enough movement to start wave?
                if value > minimalLevel {
                    //TODO: nextTriggerMoment - currentMoment! <= 0.001 moet hier uit?
                    //The beat we're in plus one is the next trigger moment
                    let nextTriggerMoment = Double(Int(currentMoment!) + 1)
                    //If the next trigger moment is very close by go ahaed already
                    if nextTriggerMoment - currentMoment! <= 0.001 {
                        //Start wave of slave type tracks
                        let startTypes: [InstrumentsSet.Track.StartType] = [.triggerSlave, .triggerSlaveMaxIndex]
                        set.tracks.filter { startTypes.contains($0.startType) }.forEach {
                            playTrack($0)
                        }
                        
                        //Track wave globaly
                        trackWaveActive[damperTarget.trackId] = true
                    }
                    else{
                        //Trigger not yet...
                        scorePartWatingToChange[damperTarget.trackId] = nextTriggerMoment
                    }
                }
            }
            //Store value for comparising within this function
            trackWavePreviousValue[damperTarget.trackId] = value
        }
    }
    
    private func waveTrigger(for damperTarget: InstrumentsSet.Track.Part.DamperTarget, test value: Double) -> Bool {
        
        //Returns true on the moment of action in a wave
        //false on all other moments
        //The mimimal amount of movement before looking up a trigger, defaults to 0.01
        //Low minimal values give more unwanted trigger moments
        let minimalLevel = damperTarget.nodeSettings?.minimalLevel ?? 0.01
        //Return value
        var actionInWave: Bool = false
        //Where are we in time on moment off call
        let currentPosition = trackSequencers[damperTarget.trackId]!.currentPosition
        //Cooldown time per wave. Defaults to 4 beats
        let coolDowntime = damperTarget.nodeSettings?.coolDownTime ?? 4.0
        //Enough movement and no active clip and there's no trackWave in cooldown.
        //End of trackWaveActive is end of cooldown
        if value > minimalLevel && !trackWaveActive[damperTarget.trackId]! {
            //In this one case we return true
            actionInWave = true
            trackWaveActive[damperTarget.trackId]! = true
        }
        
        //Start cooldown and reset midi notes
        if value < minimalLevel && trackWaveActive[damperTarget.trackId]! && trackWaveStop[damperTarget.trackId]!.beats == 0.0  {
            trackWaveStop[damperTarget.trackId]! = currentPosition
        }
        
        //Double use of trackWaveStop causes extra test
        if trackWaveStop[damperTarget.trackId]!.beats != 0 {
            //Active track AND stop time plus cooldown time is in the PAST
            if trackWaveActive[damperTarget.trackId]! && trackWaveStop[damperTarget.trackId]! + Duration(beats: coolDowntime) < currentPosition {
                trackWaveActive[damperTarget.trackId]! = false
                trackWaveStop[damperTarget.trackId]! = Duration(beats: 0.0)
                
            }
        }
        return actionInWave
    }
    
    //MARK: Score wanderer
    
    private func scoreWandererValueToMIDIclip(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        _ clipLengths: [Double],
        _ variationType: InstrumentsSet.Track.Part.DamperTarget.MidiClipVariations){
        
        /*
         This function is not compatible with triggerScorePart
         Changing to clips (density) with offsets (chords) needs to be written out to combine scoreWandererValueToMIDIclip and triggerScorePart
         Until then both share vars for wave detection
         */
        
        print("WILL BE DEPRECATED scoreWandererValueToMIDIclip \(damperTarget.trackId) value \(value)")
            
        guard let minimalLevel = damperTarget.nodeSettings?.minimalLevel else { return }
        
        print("minimalLevel \(minimalLevel)")
            
        let currentPosition = trackSequencers[damperTarget.trackId]!.currentPosition
            
        print("currentPosition \(currentPosition)")
            
        //Cooldown time per wave. Defaults to 2 beats
        let coolDowntime = damperTarget.nodeSettings?.coolDownTime ?? 2.0
        
        print("coolDowntime \(coolDowntime)")
            
        //Enough movement and no active clip and there's no trackWave in cooldown.
        //End of trackWaveActive is end of cooldown
        if value > minimalLevel && !trackWaveActive[damperTarget.trackId]! {
            
            stopNotesTrackId(for: damperTarget.trackId)
            
            //Do your active wave init
            //Copy any but the first clips for this track
            let currentIndex = globalCurrentMIDIclip[damperTarget.trackId]!
            let nextVariation = findNextVariation(clipLengths, variationType, currentIndex)
            globalCurrentMIDIclip[damperTarget.trackId]! = nextVariation

            //Calculate start time next MIDI part
            let nextMIDIstartTime = calculateMIDIstartTime(for: nextVariation, in: clipLengths)
            copyMIDIfromMemory(
                trackId: damperTarget.trackId,
                midiStartTime: nextMIDIstartTime,
                loopLength: clipLengths[triggerCurrentMIDIpart[damperTarget.trackId]!])
            
            trackWaveActive[damperTarget.trackId]! = true
        }
        
        //Start cooldown and reset midi notes
        if value < minimalLevel && trackWaveActive[damperTarget.trackId]! &&
            trackWaveStop[damperTarget.trackId]!.beats == 0.0  {
            
            //Copy first index back to running sequencer
            let firstIndexMidiClip = 0
            copyMIDIfromMemory(
                trackId: damperTarget.trackId,
                midiStartTime: Double(firstIndexMidiClip),
                loopLength: clipLengths[firstIndexMidiClip])
            
            trackWaveStop[damperTarget.trackId]! = currentPosition
        }
        
        //Double use of trackWaveStop causes extra test
        if trackWaveStop[damperTarget.trackId]!.beats != 0 {
            
            //Active track AND stop time plus cooldown time is in the PAST
            if trackWaveActive[damperTarget.trackId]! && trackWaveStop[damperTarget.trackId]! + Duration(beats: coolDowntime) < currentPosition {
                
                trackWaveActive[damperTarget.trackId]! = false
                trackWaveStop[damperTarget.trackId]! = Duration(beats: 0.0)
                
            }
        }
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
    
    private func scoreWandererRampToMIDIclip(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        _ clipLengths: [Double],
        _ variationType: InstrumentsSet.Track.Part.DamperTarget.MidiClipVariations
    ){
        //range 0.1 delen door het aantal clips
        let singleClipRange: Double = 1.0 / ( Double( clipLengths.count ) )
        
        let currentClip = Int( value / singleClipRange )
        
        if currentClip != globalCurrentMIDIclip[damperTarget.trackId] {
            
            stopNotesTrackId(for: damperTarget.trackId)
            
            let nextMIDIstartTime = calculateMIDIstartTime(for: currentClip, in: clipLengths)
            copyMIDIfromMemory(
                trackId: damperTarget.trackId,
                midiStartTime: nextMIDIstartTime,
                loopLength: clipLengths[triggerCurrentMIDIpart[damperTarget.trackId]!])
            
            globalCurrentMIDIclip[damperTarget.trackId] = currentClip
        }
        
    }
    
    private func findNextVariation(
        _ clipLengths: [Double],
        _ variationType: InstrumentsSet.Track.Part.DamperTarget.MidiClipVariations,
        _ currentIndex: Int
    ) -> Int {
        
        var foundIndex: Int = 0
        
        if variationType == .anyButFirst {
            
            var allButFirst = clipLengths
            allButFirst.removeFirst()
            foundIndex = Int(allButFirst.indices.randomElement()!)
            foundIndex += 1
        }
        else if variationType == .increaseWithValue {
            
            
            
        }
        else if variationType == .nextLoop {
            
            let totalClip: Int = clipLengths.count
            if currentIndex + 1 >= totalClip {
                foundIndex = 0
            }
            else {
                foundIndex = currentIndex + 1
            }
        }
        
        return foundIndex
    }
    
    private func scoreWandererBeatsToMIDIclip(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget,
        _ clipPlayLengths: [Int],
        _ clipLengths: [Double],
        currentSetLevel: Double ){
        
        guard let minimalLevel = damperTarget.nodeSettings?.minimalLevel else { return }
        
        let totalAmountMIDIparts = clipLengths.count
        
        //Add trackWaveActive[damperTarget.trackId] == false for cool down?
        if value > minimalLevel {
            
            //where are we in time according to running sequencer
            let currentPosition = trackSequencers[damperTarget.trackId]!.currentPosition
            
            //Track / InstrumentsSet / scoreWalkDuration [Int]?
            //How many beats to incraese to for next MIDI part
            //Index 0 is level 1 duration, Index 1 is level 2 duration
            let currentScoreWalkDuration = Double(clipPlayLengths[Int(currentSetLevel)])
            
            //New wave, set start time
            if !trackWaveActive[damperTarget.trackId]! {
                trackWaveActive[damperTarget.trackId] = true
                trackWaveInCooldown[damperTarget.trackId] = true
                //Wave take off time
                trackWaveStart[damperTarget.trackId] = currentPosition
            }
            
            //length of wave so far in beats
            let waveLength: Duration = currentPosition - trackWaveStart[damperTarget.trackId]!
            //TODO connect to wave indicator
            
            //amount of beats since update currentPosition
            if waveLength.beats > currentScoreWalkDuration {
                
                //Reset take off time
                trackWaveStart[damperTarget.trackId] = currentPosition
                
                //Increment MIDI clip number as long as there are clips
                if triggerCurrentMIDIpart[damperTarget.trackId]! + 1 < totalAmountMIDIparts {
                    //Increment to next MIDI part
                    triggerCurrentMIDIpart[damperTarget.trackId]! += 1
                    
                    //Calculate start time next MIDI part
                    let currentMIDIstartTime = calculateMIDIstartTime(for: triggerCurrentMIDIpart[damperTarget.trackId]!, in: clipLengths)
                    
                    copyMIDIfromMemory(trackId: damperTarget.trackId, midiStartTime: currentMIDIstartTime, loopLength: clipLengths[triggerCurrentMIDIpart[damperTarget.trackId]!])
                }
            }
        }
        else {
            if trackWaveActive[damperTarget.trackId]! {
                
                //where are we in time according to running sequencer
                let currentPosition = trackSequencers[damperTarget.trackId]!.currentPosition
                
                if trackWaveInCooldown[damperTarget.trackId]! {
                    trackWaveStart[damperTarget.trackId]! = currentPosition
                    trackWaveInCooldown[damperTarget.trackId] = false
                }
                
                //Use currentScoreWalkDuration as cooldown but 4 times as fast
                let commingScoreWalkDuration = Double(clipPlayLengths[Int(currentSetLevel)]) * 0.25
                
                //length of wave so far in beats
                let waveLength: Duration = currentPosition - trackWaveStart[damperTarget.trackId]!
                //TODO connect to wave indicator
                
                //amount of beats since update currentPosition
                if waveLength.beats > commingScoreWalkDuration {
                    
                    if triggerCurrentMIDIpart[damperTarget.trackId]! - 1 > 0 {
                        triggerCurrentMIDIpart[damperTarget.trackId]! -= 1
                        trackWaveInCooldown[damperTarget.trackId] = true
                    }
                    else{
                        trackWaveActive[damperTarget.trackId]! = false
                        triggerCurrentMIDIpart[damperTarget.trackId]! = 0
                    }
                    
                    //Calculate start time next MIDI part
                    let currentMIDIstartTime = calculateMIDIstartTime(for: triggerCurrentMIDIpart[damperTarget.trackId]!, in: clipLengths)
                    
                    copyMIDIfromMemory(trackId: damperTarget.trackId, midiStartTime: currentMIDIstartTime, loopLength: clipLengths[triggerCurrentMIDIpart[damperTarget.trackId]!])
                }
            }
        }
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

    private func switchTrackMidiPart(_ track: InstrumentsSet.Track, _ maxIndex: Int) {
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
    // Play a track
    private func playTrack(_ track: InstrumentsSet.Track) {
        
        trackSequencers[track.id]?.play()
    }
    // Stop a track
    private func stopTrack(_ track: InstrumentsSet.Track) {
        trackSequencers[track.id]?.stop()
        trackSequencers[track.id]?.rewind()
        trackSequencers[track.id]?.preroll()
    }
    
    private func envDownTracks(_ track: InstrumentsSet.Track) {
        let trackOff = MIDIEvent(noteOn: MIDINoteNumber(64), velocity: 0, channel: 1)
        trackAmpEnvelopes[track.id]!.scheduleMIDIEvent(event: trackOff)
    }
    
    private func stopNotesTrackId(for trackId: String) {
        
        //Shut down all note on's
        for note in 0...127 {
            trackSamplers[trackId]!.stop(noteNumber: MIDINoteNumber(note), channel: 1)
        }
    }
    
    func togglePlayEngineAndTracks(
        currentSetLevel: Double,
        setSettings: SetSettings
    ) {
        
        if isConductorPlayingSubject.value {
            pauzeEngineAndStopTracks(setSettings: setSettings)
            
        }
        else {
            print("Mute here before play?")
            
            playEngineAndTracks()
            //Fade in on master play, we need level.currentlevel here
            trackMuteAndClipStatusPerLevelControl(
                level: Int(currentSetLevel),
                setSettings: setSettings,
                from: "togglePlay"
            )
        }
    }
    
    func playEngineAndTracks() {
        
        guard !isConductorPlayingSubject.value else { return }
        
        do {
            //Variable for use in View (SwiftUI)
            isConductorPlayingSubject.send(true)
            //Fire up the audio engine
            try audioEngine.start()
            
            // OLD Play all tracks that don't have a startType of triggerSlave
            
            // NEW, Start global tracks
            // - .global are tracks with midi files in sequencers
            // - .globalMidi are tracks with just notenumbers, without sequencer
            let startTypes: [InstrumentsSet.Track.StartType] = [.global,.globalMidiData]
            set.tracks.filter { startTypes.contains($0.startType) }.forEach {
                if $0.startType == .global{ playTrack($0) }
                if $0.startType == .globalMidiData {
                    if $0.instrumentType == .allValues {
                        playMidiDataAllValues(with: $0)
                    }
                    else{
                        playMidiData(with: $0.parts.first!.damperTarget)
                    }
                }
            }
        } catch {
                isConductorPlayingSubject.send(false)
        }
    }
    
    func playEngineUIEffect() {
        do {
            //Fire up the audio engine
            try audioEngine.start()
        } catch {
                print("Engine not started")
        }
    }
    
    func pauzeEngineAndStopTracks(setSettings: SetSettings) {
        
        guard isConductorPlayingSubject.value else { return }
        
        set.tracks.forEach {
            envDownTracks($0)
            stopTrack($0)
        }
        audioEngine.pause()
        isConductorPlayingSubject.send(false)
    }
    
    
}
