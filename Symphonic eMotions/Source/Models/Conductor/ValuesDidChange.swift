//
//  ValuesDidChange.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit
import Accelerate

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
        
        //The level updater
        localCurrentSetLevel = getAndOrIncreaseCurrentSetLevel(
            currentSetLevel: currentSetLevel,
            value: averageForLevelupdate
        )
        
        //Make a global maxIndex to go in and out of if areaOfInterest is just 1 cell
        let scaledValues = values.flatMap { $0.map { $0.scaledValue } }
        let maxIndexTupple = vDSP.indexOfMaximum(scaledValues)
        //We only need the index for triggering
        let maxIndex = Int(maxIndexTupple.0)
    
        //We iterate through all tracks and its parts
        var trackNr: Int = 0
        var partNr: Int = 0
        setSettings.tracks.forEach { (trackIndex,track) in
            
            //Reset part per track
            partNr = 0
            
            //No parts return
            if track.parts.count == 0 {
                return
            }
            
            //Loop through all parts per track per value
            track.parts.forEach { (partIndex,part) in
                
                //We get the value from the areas of interest
                let valuesMapped = part.interestIndexes(
                    rows: setSettings.gridRows,
                    columns: setSettings.gridColumns).map {
                        values[$0.row][$0.column].scaledValue
                }
                
                guard !valuesMapped.isEmpty else { return }
                
                //Find highest value (maximum) with it's index
                let maxIndexPartTupple = vDSP.indexOfMaximum(valuesMapped)
                                
                //Have a var for MaxIndex to number of MidiClips range
                let maxIndexPart = Int(maxIndexPartTupple.0)
                
                //MaxMapped (highest value found in all of AreaOfInterest) value to work with
                var value = maxIndexPartTupple.1
                if value.isNaN {
                    value = 0
                }
                
                //MARK: First part Type controlling
                //NoteSource -> midi || note number
                //StartType -> Transport || Wave (loopedTriger)
                //TrackType -> Variation by level || position
                if partNr == 0 {
                    
                    //Decide WHAT to play for midi
                    //.variationByLevel sits in self.levelController
                    
                    //For notenumner one shot play direct
                    if track.trackType == .variationByPosition {
                        
                        //Make sure its not the original but the mapped maxIndex
                        if track.noteSource == .midiFile && track.loopsToGridMapped[maxIndexPart] != track.loopsToGridMapped[track.currentPartMaxIndex] {
                            
                            //This is the mapped value from the editor .midiFile .variationByPosition
                            let loopIndex = track.loopsToGridMapped[maxIndexPart]
                            
                            if loopIndex != track.currentLoopIndex {
                                
                                let nextMIDIstartTime = calculateMIDIstartTime(
                                    for: loopIndex,
                                    in: track.loopLength
                                )
                                
                                copyMIDIfromMemory(
                                    trackId: track.trackId,
                                    midiStartTime: nextMIDIstartTime,
                                    loopLength: track.loopLength[loopIndex])
                                
                                track.currentLoopIndex = loopIndex
                                track.currentPartMaxIndex = maxIndexPart
                            }
                        }
                        
                        //Make sure its not the original but the mapped maxIndex
                        else if track.noteSource == .noteNumbers {
                            
                            if [.loopedTrigger,.oneShot].contains(track.startType) {
                                
                                let noteNumber:Int = track.notesToGridMapped[maxIndexPart]
                                track.playThisNote = noteNumber
                            }
                        }
                        
                        track.currentPartMaxIndex = maxIndexPart
                        track.currentMaxIndex = maxIndex
                    }
                    
                    //Levels Midi
//                    else if track.trackType == .variationByLevel && Int(localCurrentSetLevel) != track.currentLevel && track.noteSource == .midiFile {
//
//
//
//                        //This is the chosen note number in the editor NoteNumberToLevelView()
//                        let noteNumber:Int = track.notesToLevel[Int(localCurrentSetLevel)]
//                        track.playThisNote = noteNumber
//                        track.currentLevel = Int(localCurrentSetLevel)
//                    }
                    //Levels Note numbers
                    else if track.trackType == .variationByLevel && Int(localCurrentSetLevel) != track.currentLevel && track.noteSource == .noteNumbers {
                        
                        for note in track.notesArePlaying {
                            stopNoteNumber(track, note)
                        }
                        
                        //This is the chosen note number in the editor NoteNumberToLevelView()
                        let noteNumber:Int = track.notesToLevel[Int(localCurrentSetLevel)]
                        track.playThisNote = noteNumber
                        track.currentLevel = Int(localCurrentSetLevel)
                    }
                    
                    
                    
                    //Midi File Position Wave player, start with movement
                    if track.noteSource == .midiFile && [.loopedTrigger,.oneShot].contains(track.startType) {
                        if setSettings.isWavePlaying {
                            //End wave under treshold
                            if value < setSettings.waveThreshold {
                                //looped is always for all tracks
                                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                                     stopTrack($0)
                                }
                                setSettings.isWavePlaying = false
                            }
                        }
                        //No wave
                        else {
                            if value > setSettings.waveThreshold {
                                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                                    playTrack($0)
                                }
                                setSettings.isWavePlaying = true
                            }
                        }
                    }
                    
                    //Note Number / Wave player = start with movement
                    else if track.noteSource == .noteNumbers && [.loopedTrigger,.oneShot].contains(track.startType) {
                        
                        //End all notes:
                        if value < setSettings.waveThreshold {
                            for note in track.notesArePlaying { stopNoteNumber(track, note) }
                            track.notesArePlaying = []
                        }
                        else{
                            
                            //Play note if area active
                            if part.areaOfInterest[maxIndex] == 1 && !track.notesArePlaying.contains(track.playThisNote) {
                                
                                playNoteNumber(track, track.playThisNote)
                                //Add it to the playing note array
                                if !track.notesArePlaying.contains(track.playThisNote) {
                                    track.notesArePlaying.append(track.playThisNote)
                                }
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
                    
                    let maxIndexMapped = track.loopsToGridMapped[maxIndexPart]
                    //Send 0 for a value if not in level
                    let inLevel: Double = track.levels.contains([Int(localCurrentSetLevel)]) ? 1 : 0
                    forwardSpriteKit(
                        trackNr: trackNr,
                        partNr: partNr,
                        ramped: value * inLevel,
                        areaOfInterest: part.areaOfInterest,
                        maxIndex: maxIndexPart,
                        mappedIndex: maxIndexMapped
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
