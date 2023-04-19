//
//  ValuesDidChange.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit
//import SoundpipeAudioKit
//import AVFAudio
import Accelerate
//import Combine
//import Dispatch

extension Conductor {
    
    internal func valuesDidChange(
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
        
        //Levels are updated with movement
        var localCurrentSetLevel: Double = currentSetLevel
        
        //Level update is done the average value
        let averageForLevelupdate: Double = values.flatMap { $0 }
            .map { $0.average }
            .reduce(0, +) / Double(values.flatMap { $0 }.count)
        localCurrentSetLevel = getAndOrIncreaseCurrentSetLevel(
            levelSpeed: setSettings.levelSpeed,
            currentSetLevel: currentSetLevel,
            value: averageForLevelupdate
        )
        
        //We iterate through all tracks and its parts
        var trackNr: Int = 0
        var partNr: Int = 0
        setSettings.tracks.forEach { (trackIndex,track) in
            //Reset part per track
            partNr = 0
            
            //If muted return
//            if track.muted != nil && track.muted == true {return}
            
            //No parts return
            if track.parts.count == 0 {
                return
            }
            
            //Here we look up the trigger method
            let noteSource = track.noteSource
            let startType = track.startType
            let trackType = track.trackType
            
            
            //Version checklist
//            NoteSource.midiFile
//            StartType.loopedTrigger
//            StartType.oneShot
//            TrackType.variationByPosition
//            TrackType.variationByIntensity
//
//            NoteSource.noteNumbers
//            StartType.loopedTrigger
//            StartType.oneShot
//            TrackType.variationByPosition
//            TrackType.variationByIntensity
            
            //Loop through all parts per track per value
            track.parts.forEach { (partIndex,part) in
                
                //We get the value from the areas of interest
                let valuesMapped = part.indexes(
                    rows: setSettings.gridRows,
                    columns: setSettings.gridColumns).map {
                        values[$0.row][$0.column].scaledValue
                    }
                guard !valuesMapped.isEmpty else { return }
                
                //Find highest value (maximum) with it's index
                let maxIndexTupple = vDSP.indexOfMaximum(valuesMapped)
                                
                //Have a var for MaxIndex to number of MidiClips range
                let maxIndexraw = Int(maxIndexTupple.0)
                var maxIndexMidiClips = maxIndexraw
                
                //MaxMapped (highest value found in all of AreaOfInterest) value to work with
                var value = maxIndexTupple.1
                if value.isNaN {
                    value = 0
                }
                
                //MARK: Handle clip and note control with first part
                if partNr == 0 {
                    
                    //Decide WHAT to play
                    if track.trackType == .variationByPosition {
                        
                        if track.noteSource == .midiFile {
                            
                            //This is the mapped value from the editor .midiFile .variationByPosition
                            let loopLengthIndex = track.loopsToGridMapped[maxIndexMidiClips]
                            let nextMIDIstartTime = calculateMIDIstartTime(
                                for: loopLengthIndex,
                                in: track.loopLength
                            )
                            
                            copyMIDIfromMemory(
                                trackId: track.trackId,
                                midiStartTime: nextMIDIstartTime,
                                loopLength: track.loopLength[loopLengthIndex])
                        }
                        else if track.noteSource == .noteNumbers {
                            
                            //This is the chosen note number in the editor NoteNumberToGrid()
                            let noteNumber:Int = track.notesToGrid[maxIndexMidiClips]
                            track.noteIsPlaying = noteNumber
                        }
                    }
                    else if track.trackType == .variationByLevel && track.noteSource == .noteNumbers {
                        
                        //This is the chosen note number in the editor NoteNumberToLevelView()
                        let noteNumber:Int = track.notesToLevel[Int(localCurrentSetLevel)]
                        track.noteIsPlaying = noteNumber
                    }
                    
                    //If not playing by transport start playing here for looped start typed
                    if [.loopedTrigger].contains(track.startType) {
                        if setSettings.isWavePlaying {
                            //End wave under treshold
                            if value < setSettings.waveThreshold {
                                //looped is always for all tracks
                                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                                    if $0.noteSource == .midiFile { stopTrack($0) }
                                    if $0.noteSource == .noteNumbers {
                                        stopNoteNumber($0, track.noteIsPlaying)
                                        track.noteIsPlaying = 0
                                    }
                                }
                                setSettings.isWavePlaying = false
                            }
                        }
                        //No wave
                        else {
                            if value > setSettings.waveThreshold {
                                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                                    if $0.noteSource == .midiFile { playTrack($0) }
                                    if $0.noteSource == .noteNumbers { playNoteNumber($0, track.noteIsPlaying) }
                                }
                                setSettings.isWavePlaying = true
                            }
                        }
                    }
                }
                //End first Part
                
                //All parts
                //Ad damping curves
                value = valueDamper(dampMode: part.damperTarget.dampMode!, value: value)
                //Ad ramps from interface!
                value = valueRamper(value: value, rampId: partIndex)
                
                //Forward to target
                forward(
                    value: value,
                    for: part.damperTarget,
                    currentSetLevel: localCurrentSetLevel
                )
                
                //User interface feedback
                if setSettings.defaultSkin == .spriteKit {
                    
                    //FIXME: maxIndexMidiClips has no difference with maxIndexraw
                    //Find out why different is needed and correct with track.loopsToGridMapped
                    
                    forwardSpriteKit(
                        trackNr: trackNr,
                        partNr: partNr,
                        ramped: value,
                        areaOfInterest: part.areaOfInterest,
                        maxIndexRaw: maxIndexraw,
                        maxIndex: maxIndexMidiClips
                    )
                }
                else if setSettings.defaultSkin == .swiftUI {
                    //Check part feedback interface state for part feedback visualisation
                    if partFeedbackTrackID == trackIndex && partFeedbackPartID == partIndex {
                        forwardPartFeedback(
                            ramped: value
                        )
                    }
                }
                
                partNr += 1
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
}
