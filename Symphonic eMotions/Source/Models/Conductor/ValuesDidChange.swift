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
        var maxScaledValue: Double = -1  // To store the maximum scaled value
        values.forEach { areaValues in
            areaValues.forEach { value in
                sum += value.average
                count += 1
                scaledValues.append(value.scaledValue)
                // Update maxScaledValue if it's either nil or smaller than the current scaledValue
                if value.scaledValue > maxScaledValue {
                    maxScaledValue = value.scaledValue
                }
            }
        }

        // Compute average
        let averageForLevelUpdate = sum / Double(count)
        
        //TODO: Make level type switch
        // Increment the current level
//        localCurrentSetLevel = getAndOrIncreaseCurrentSetLevel(
//            currentSetLevel: currentSetLevel,
//            value: averageForLevelUpdate
//        )
        
        // Increment AND decrement level
        localCurrentSetLevel = adjustCurrentSetLevel(
            setSettings: setSettings,
            currentSetLevel: currentSetLevel,
            averageMovement: averageForLevelUpdate
        )
                
        //Wave mechanism (start and stop on movement)
        //End of wave, stop playing
        if setSettings.isWavePlaying {
            if maxScaledValue < setSettings.waveUnderLevel {
                setSettings.isWavePlaying = false
//                print("Stop all tracks")
                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                    stopTrack($0)
                }
            }
        }
        //Start playing on movement
        else {
            if maxScaledValue > setSettings.waveUnderLevel {
                
                //TODO: wait buffer frame count treshold
                
                setSettings.isWavePlaying = true
//                print("Play play tracks")
                setSettings.tracks.values.filter { [.loopedTrigger].contains($0.startType) }.forEach {
                    playTrack($0)
                }
            }
        }
 
        // Find the maximum index (used for variation by position)
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
                
                // get current and previous value from values
                let interestIndexes = part.interestIndexes(rows: setSettings.gridRows, columns: setSettings.gridColumns)
                let valuesMapped = interestIndexes.map { index -> (current: Double, previous: Double) in
                    (current: values[index.row][index.column].scaledValue, previous: values[index.row][index.column].previousScaledValue)
                }
                
                let currentValues = valuesMapped.map { $0.current }
                let previousValues = valuesMapped.map { $0.previous }
                
                // Find highest value (maximum) with its index
                let maxIndexPartTuple = vDSP.indexOfMaximum(currentValues)
                let maxIndexPart = Int(maxIndexPartTuple.0)
                var value = maxIndexPartTuple.1.isNaN ? 0 : maxIndexPartTuple.1
                let previousValue = previousValues.indices.contains(maxIndexPart) ? previousValues[maxIndexPart] : 0
                
                //MARK: Timed movement envelope (Replaced ramps and damps)
                if let envelope = timeBasedEnvelopes[partIndex] {
                    // Safe access to custom rates with default value fallback
                    let customDecreaseRate = (rampDown[partIndex] ?? 0.5) * 0.1
                    let customIncreaseRate = (rampUp[partIndex] ?? 0.5) * 0.1
                    
                    // This is the instrument / effect controller
                    value = envelope.updateEnvelope(
                        withMovement: value,
                        previousMovement: previousValue,
                        decreaseRate: customDecreaseRate,
                        increaseRate: customIncreaseRate
                    )
                }
                
                //Level controls the amount of instrument controller
                let progress = levelProgressForController(
                    track.levels,
                    currentLevel: localCurrentSetLevel
                )
                
                value *= progress
                
                
                //MARK: First part Type controlling
                //NoteSource -> midi || note number
                //StartType -> Transport || Wave (loopedTriger)
                //VariationType -> Variation by level || position
                if partNr == 0 {
                    
//                    track.currentMaxIndex = maxIndex
                    
                    //MARK: WHAT to play for midi and note numbers
                    //.variationByLevel sits in self.levelController
                    
                    //Midi files variation and wave start
                    if track.noteSource == .midiFile {
                        
                        //Midi file variation check if instrument is placed
                        if track.variationType == .variationByPosition && track.loopsToGridMapped.count > 0 {
                            
                            
                            //We have a new postition
                            if track.loopsToGridMapped.indices.contains(maxIndexPart) 
                                && track.loopsToGridMapped.indices.contains(track.currentPartMaxIndex)
                            {
                                if track.loopsToGridMapped[maxIndexPart] != track.loopsToGridMapped[track.currentPartMaxIndex] {
                                    
                                    //This is the mapped value from the editor .midiFile .variationByPosition
                                    let loopIndex = track.loopsToGridMapped[maxIndexPart]
                                    track.currentPartMaxIndex = maxIndexPart
                                    
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
                                    }
                                }
                                
                            }
                        }
                    }
                    //Note number wave start
                    else if track.noteSource == .noteNumbers {
                        
                        //Play with wave, end all notes after wave
                        if [.loopedTrigger].contains(track.startType) {
                            
                            //Levels are triggered alsewhere
                            if track.variationType == .variationByPosition {
                                
                                //waveUnderLevel is currently: firstMinimalLevel * 0.5
                                if value < setSettings.waveUnderLevel {
                                                                    
                                    for maxIndex in track.notesArePlaying {
                                        
                                        let noteNumber = track.notesToGrid[maxIndex]
                                        
                                        stopSamplerNote(track, noteNumber)
                                        
                                    }
                                    track.notesArePlaying = []
//                                    print("stopping all notes")
                                }
                                else{
                                    
                                    if value > part.minimalLevel
                                        && part.areaOfInterest[maxIndex] == 1
                                        && !track.notesArePlaying.contains(maxIndex) {
                                        
                                        playSamplerNote(track, track.notesToGrid[maxIndex])
                                        
                                        print("noteNumbers loopedTrigger PLAY NOTE \(maxIndex):\(track.notesToGrid[maxIndex])")
                                        
                                        track.notesArePlaying.append(maxIndex)
                                    }
                                }
                            }
                        }
                    }
                }
                //End first Part
                
        
                //All parts
                //Forward to target
                forward(
                    value: value,
                    for: part.damperTarget,
                    currentSetLevel: localCurrentSetLevel
                )
                
                //User interface feedback
                if setSettings.defaultSkin == .home {
                    
                    if trackNr == 1 {
                        let isPlaying: Double = userSettings.isSetPlaying ? 1 : 0
                        rotationSpeedSubject.send(value * isPlaying)
                    }
                }
                if setSettings.defaultSkin == .spriteKit {
                        
//                    print("track.loopsToGridMapped \(track.loopsToGridMapped)")
                    
                    let maxIndexMapped = track.loopsToGridMapped[maxIndexPart]
//
//                    //Send 0 for a value if not in level
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
