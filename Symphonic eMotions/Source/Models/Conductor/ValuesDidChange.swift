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
                
                //MARK: index to midi clip conversion
                //Change order of indeces for mapping with events
                if track.trackType == .variationByPosition && partNr == 0 {
                    
                    let mapMaxIndex = track.loopsToGridMapped
                    
                    if track.noteSource == .midiFile {
                        
                        maxIndexMidiClips = mapMaxIndex[maxIndexMidiClips]
                        forwardMaxIndex(
                            for: part.damperTarget,
                            maxIndex: maxIndexMidiClips
                        )
                    }
                }
                
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
