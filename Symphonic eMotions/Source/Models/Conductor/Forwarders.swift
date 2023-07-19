//
//  Forwarders.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/04/2023.
//

import AudioKit

extension Conductor {
    
    public func forwardMasterTrackEffect(
        value: Double,
        nodeName: String,
        parameter: String,
        parameterRange: [Double] ) {
        
        let effectType = InstrumentsSet.Track.Effect.EffectType(rawValue: nodeName)
        
        let effect = set.effect(for: effectType!)
        
        effect!.targetAndApply(value: value, nodeName: nodeName, parameter: parameter, parameterRange: parameterRange)
    }
    
    //Forward Part Feedback
    internal func forwardPartFeedback( ramped: Double ) -> Void {
        forwardRampedPartFeedback.send(ramped)
    }
    
    internal func forwardEffect(
        value: Double,
        for damperTarget: InstrumentsSet.Track.Part.DamperTarget) {
        
        guard let track = set.track(for: damperTarget.trackId) else { return }
        
        guard let effectType = InstrumentsSet.Track.Effect.EffectType(rawValue: damperTarget.nodeName) else { return }
        
        guard let effect = track.effect(for: effectType) else { return }
        
        effect.apply(value: value, with: damperTarget)
    }
    
    internal func forwardSpriteKit(
        trackNr: Int,
        partNr: Int,
        ramped: Double,
        areaOfInterest: [Int],
        maxIndex: Int,
        mappedIndex: Int
    ) -> Void {
        
//        let allCells = areaOfInterest.filter { int in
//            return int == 1
//        }
        //Reverse maxIndexes for inverted Y axis in SpriteKit
//        let reversed = reverseNumber(number: maxIndexRaw, min: 0, max: allCells.count - 1)
        
//        print("*** forwardSpriteKit trackNr: \(trackNr) partNr: \(partNr) ramped: \(ramped) areaOfInterest: \(areaOfInterest) maxIndex: \(maxIndex) mappedIndex: \(mappedIndex) ")
//        
        if trackNr == 0 {
            if partNr == 0 {
                spriteKitParts0a.send((maxIndex,mappedIndex,ramped))
            }
            else if partNr == 1 {
                spriteKitParts0b.send((maxIndex,mappedIndex,ramped))
            }
        }
        else if trackNr == 1 {
            if partNr == 0 {
                spriteKitParts1a.send((maxIndex,mappedIndex,ramped))
                
            }
            else if partNr == 1 {
                spriteKitParts1b.send((maxIndex,mappedIndex,ramped))
            }
        }
        else if trackNr == 2 {
            if partNr == 0 {
                spriteKitParts2a.send((maxIndex,mappedIndex,ramped))
            }
            else if partNr == 1 {
                spriteKitParts2b.send((maxIndex,mappedIndex,ramped))
            }
        }
        else if trackNr == 3 {
            if partNr == 0 {
                spriteKitParts3a.send((maxIndex,mappedIndex,ramped))
            }
            else if partNr == 1 {
                spriteKitParts3b.send((maxIndex,mappedIndex,ramped))
            }
        }
    }
    
    //Forward damper data
    internal func forward(
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
    
    internal func forwardInstrumment(value: Double, on trackId: String, for parameter: String) {
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
    
    internal func forwardSequencer(
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
                } else { velocities[track.id] = 0 }
                
            case "soundModuleParam01":
                
                guard let track = set.track(for: damperTarget.trackId) else { return }
                soundModuleParam01[track.id] = value
            case "soundModuleParam02":
                
                guard let track = set.track(for: damperTarget.trackId) else { return }
                soundModuleParam02[track.id] = value
            
            default:
                print("Sequencer damperTarget.parameter Not mapped: \(damperTarget.parameter)")
                return
        }
    }
}
