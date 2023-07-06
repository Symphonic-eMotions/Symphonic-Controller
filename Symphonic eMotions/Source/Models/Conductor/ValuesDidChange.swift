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

        // Flatten the 2D list and compute the sum, count and maximum in a single pass
        var sum = 0.0
        var count = 0
        var scaledValues: [Double] = []
        values.forEach { areaValues in
            areaValues.forEach { value in
                sum += value.average
                count += 1
                scaledValues.append(value.scaledValue)
            }
        }

        // Compute average
        let averageForLevelUpdate = sum / Double(count)

        // Update the current level
        localCurrentSetLevel = getAndOrIncreaseCurrentSetLevel(currentSetLevel: currentSetLevel, value: averageForLevelUpdate)

        // Find the maximum index
        let maxIndexTuple = vDSP.indexOfMaximum(scaledValues)
        let maxIndex = Int(maxIndexTuple.0)
        
        //We iterate through all tracks and its parts
        var trackNr: Int = 0
        var partNr: Int = 0
        setSettings.tracks.forEach { (trackIndex,track) in
            
            //Reset part per track
            partNr = 0
            
            //Loop through all parts per track per value
            track.parts.forEach { (partIndex,part) in
                
                //We get the value from the areas of interest
                let valuesMapped = part.interestIndexes(
                    rows: setSettings.gridRows,
                    columns: setSettings.gridColumns).map {
                        values[$0.row][$0.column].scaledValue
                }
                
//                guard !valuesMapped.isEmpty else { return }
                
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
                //VariationType -> Variation by level || position
                if partNr == 0 {
                    
//                    track.currentMaxIndex = maxIndex
                    
                    //MARK: WHAT to play for midi and note numbers
                    //.variationByLevel sits in self.levelController
                    
                    //What to play MidiFile tracks
                    if track.noteSource == .midiFile {
                        
                        if track.variationType == .variationByPosition {
                            
                            //We have a new postition
                            if track.loopsToGridMapped[maxIndexPart] != track.loopsToGridMapped[track.currentPartMaxIndex] {
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
                        }
                        
                    }
                    //Note number tracks
                    else if track.noteSource == .noteNumbers {
                        
                         if track.variationType == .variationSequencial {
                            
                            //Start with movement AND Trigger single note (not tracnsport)
                            if [.loopedTrigger,.oneShot].contains(track.startType) {
                                
                                //We trigger only if above minimalLevel treshold
                                if value > part.minimalLevel {
                                    
                                    
                                }
                            }
                        }
//                        //Note number levels
//                        else if track.variationType == .variationByLevel {
//
//                            if Int(localCurrentSetLevel) != track.currentLevel {
//
//                                for note in track.notesArePlaying {
//                                    stopNoteNumber(track, note)
//                                }
//
//                                //This is the chosen note number in the editor NoteNumberToLevelView()
//                                let noteNumber:Int = track.notesToLevel[Int(localCurrentSetLevel)]
//                                track.playThisNote = noteNumber
//                                track.currentLevel = Int(localCurrentSetLevel)
//
//                                print("Level \(Int(localCurrentSetLevel)) play note number \(noteNumber) ")
//                            }
//                        }
                    }
                    
                    //Midi File Position Wave player, start with movement
                    if track.noteSource == .midiFile &&
                        [.loopedTrigger].contains(track.startType) {
                        
                        
                        if setSettings.isWavePlaying {
                            //End wave under minimal leel first part
                            if value < setSettings.waveUnderLevel{
                                //looped is always for all tracks
                                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                                     stopTrack($0)
                                }
                                setSettings.isWavePlaying = false
                            }
                        }
                        //No wave
                        else {
                            if value > part.minimalLevel {
                                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                                    playTrack($0)
                                }
                                setSettings.isWavePlaying = true
                            }
                        }
                    }
                    
                    //Note Number / Wave player = start with movement
                    else if track.noteSource == .noteNumbers {
                        
                        //Play with wave, end all notes after wave
                        if [.loopedTrigger].contains(track.startType) {
                            
                            //End all notes when a 10% lower than first part minimalLevel
                            if value < setSettings.waveUnderLevel {
                                                                
                                for note in track.notesArePlaying {
                                    stopNoteNumber(track, note)
//                                    print("stopping \(note)")
                                }
                                track.notesArePlaying = []
                            }
                            else{
                                
                                //Play note Number && note is not already playing AND movement is above minimal level
                                if part.areaOfInterest[maxIndex] == 1 && !track.notesArePlaying.contains(track.playThisNote) && value > part.minimalLevel {
                                    
                                    playNoteNumber(track, track.playThisNote)
                                    
                                    //Add it to the playing note array
                                    if !track.notesArePlaying.contains(track.playThisNote) {
                                        
//                                        print("NM loopedTrigger WAVE PLAY \(track.playThisNote)")
                                        
                                        track.notesArePlaying.append(track.playThisNote)
                                    }
                                }
                            }
                        }
                        
                        //Play with length connected to value
                        else if [.oneShot].contains(track.startType) {
                            
                            //Play note Number && note is not already playing AND movement is above minimal level
                            if part.areaOfInterest[maxIndex] == 1 && value > part.minimalLevel {
                                
                                if track.variationType == .variationSequencial {
                                    
                                    if let currentNote = sequenceNote[track.trackId] {
                                        
                                        print("current note \(currentNote)")
                                        
                                        let noteNumber:Int = getNextSequenceNote(
                                            currentNote,
                                            track.notesSequenceType,
                                            track.midiGroup,
                                            value)
                                        sequenceNote[track.trackId] = noteNumber
                                        
                                        print("sequnced note \(noteNumber)")
                                        
                                        playNoteNumberLength(track, noteNumber, value)
                                    }
                                }
                                else if track.variationType == .variationByPosition {
                                    let noteNumber:Int = track.notesToGridMapped[maxIndexPart]
                                    playNoteNumberLength(track, noteNumber, value)
                                }
                                
                                //Record to sequencer
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
                if setSettings.defaultSkin == .home {
                    
                    if trackNr == 1 {
                        let isPlaying: Double = isSetPlaying ? 1 : 0
                        rotationSpeedSubject.send(value * isPlaying)
                    }
                }
                if setSettings.defaultSkin == .spriteKit {
                        
                    print("track.loopsToGridMapped \(track.loopsToGridMapped)")
                    
//                    let maxIndexMapped = track.loopsToGridMapped[maxIndexPart]
//
//                    //Send 0 for a value if not in level
//                    let inLevel: Double = track.levels.contains([Int(localCurrentSetLevel)]) ? 1 : 0
//                    forwardSpriteKit(
//                        trackNr: trackNr,
//                        partNr: partNr,
//                        ramped: value * inLevel,
//                        areaOfInterest: part.areaOfInterest,
//                        maxIndex: maxIndexPart,
//                        mappedIndex: maxIndexMapped
//                    )
                }
                //Koppelen aan sessionViewSub
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
}
