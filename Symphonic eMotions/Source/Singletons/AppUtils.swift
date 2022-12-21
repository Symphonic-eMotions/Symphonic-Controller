//
//  AppUtils.swift
//  AppUtils
//
//  Created by Mihai Fratu on 31.07.2021.
//

import Foundation
import SwiftUI
import AudioKit
import OrderedCollections

final class AppUtils {
    
    static func loadSets(json: String) -> Sets {
        
        guard let sets = Sets.withJSON(json) else {
            preconditionFailure()
        }
        return sets
    }
    
    static func loadInstrumentSet(json: String) -> InstrumentsSet {
        
        print("Loading \(json)")
        
        guard let instrumentSet = InstrumentsSet.withJSON(json) else {
            preconditionFailure()
        }
        return instrumentSet
    }
    
    static func loadURLServerInstrumentSet(urlServer: String) -> InstrumentsSet? {
        
        let urlServerURL = URL(string: urlServer)
        
        let instrumentSet = InstrumentsSet.withOnlineJSON(urlServerURL!)
        
        return instrumentSet ?? nil
    }
    
    static func loadSavedInstrumentSet(fileName: String) -> InstrumentsSet? {
        
        guard let instrumentSet = InstrumentsSet.withFileManagerJSON(fileName) else {
            preconditionFailure()
        }
        return instrumentSet
    }
    
    static func createWorkingFile(
        setSettings: SetSettings,
        instrumentSet: InstrumentsSet,
        duplicateLastTrack: Bool
    ) -> String {
        
        let setName = instrumentSet.name
        let timestammp = NSDate().timeIntervalSince1970
        let fileName = setName + "-timestamp-\(timestammp)"
        
        let storeInstrumentSet: InstrumentsSet = createInstrumentSet(setSettings: setSettings, instrumentSet: instrumentSet, duplicateLastTrack: duplicateLastTrack)
        
        InstrumentsSet.writeLoadedSet(setName: fileName, instrumentSet: storeInstrumentSet)
        
        return fileName
    }
    
    static func createInstrumentSet(
        setSettings: SetSettings,
        instrumentSet: InstrumentsSet,
        duplicateLastTrack: Bool
    ) -> InstrumentsSet {
        
        //Get modified master track effect settings and store them in encodable format
        //Modified data store in: setSettings.masterEffects
        let currentMasterEffects: [InstrumentsSet.Track.Effect] = instrumentSet.masterTrackEffects
        var modifiedMasterEffects: [InstrumentsSet.Track.Effect] = []
        for (effectIndex, currentMasterEffect) in currentMasterEffects.enumerated() {
            
            let effectType: InstrumentsSet.Track.Effect.EffectType = currentMasterEffect.effectType
            var parameters: [ValueAndRange] = []
            
            let parameterStrings: [String] = currentMasterEffect.effectVars(effectType: effectType)
            for (parameterIndex, parameterString) in parameterStrings.enumerated() {
                let loadedValueAndRange = currentMasterEffect.valueAndRanges(parameter: parameterString)!
                let loadedRange = loadedValueAndRange.range
                let storedValue = setSettings.masterEffects[effectIndex]?.parameters[parameterIndex]!.value
                parameters.append( ValueAndRange(value: AUValue( storedValue! ), range: loadedRange) )
            }
            
            let modifiedMasterEffect = InstrumentsSet.Track.Effect(effectType: effectType, parameters: parameters)
            modifiedMasterEffects.append(modifiedMasterEffect)
        }
        
        //Replace loaded data with modified data within tracks
        // - rampSpeed (InstrumentsSet.Track.Part.DamperTarget.NodeSettings.rampSpeed)
        // - rampSpeedDown (InstrumentsSet.Track.Part.DamperTarget.NodeSettings.rampSpeedDown)
        // - volume (InstrumentsSet.Track.volume)
        // - instrumentColor (InstrumentsSet.Track.instrumentColor)
        // - areaOfInterest (InstrumentsSet.Track.Part.areaOfInterest
        var storeTracks: [InstrumentsSet.Track] = []
        for track in instrumentSet.tracks {
            
            var storeParts: [InstrumentsSet.Track.Part] = []
            for part in track.parts {
                
                let storeNodeSettings = InstrumentsSet.Track.Part.DamperTarget.NodeSettings(
                    minimalLevel: part.damperTarget.nodeSettings!.minimalLevel,
                    levelPart: part.damperTarget.nodeSettings?.levelPart,
                    tempoLow: part.damperTarget.nodeSettings?.tempoLow,
                    tempoHigh: part.damperTarget.nodeSettings?.tempoHigh,
                    
                    rampSpeed: setSettings.tracks[track.trackId]!.parts[part.id]!.rampUp,
                    rampSpeedDown: setSettings.tracks[track.trackId]!.parts[part.id]!.rampDown,
                    
                    coolDownTime: part.damperTarget.nodeSettings?.coolDownTime
                )
                
                let storeDamperTarget = InstrumentsSet.Track.Part.DamperTarget(
                    trackId: part.damperTarget.trackId,
                    nodeType: part.damperTarget.nodeType,
                    scoreWandererType: part.damperTarget.scoreWandererType,
                    midiClipVariation: part.damperTarget.midiClipVariation,
                    nodeName: part.damperTarget.nodeName,
                    parameter: part.damperTarget.parameter,
                    parameterRange: part.damperTarget.parameterRange,
                    midiData: part.damperTarget.midiData,
                    nodeSettings: storeNodeSettings,
                    dampMode: part.damperTarget.dampMode
                )
                
                let storePart = InstrumentsSet.Track.Part(
                    instrumentPartName: part.instrumentPartName,
                    
                    areaOfInterest: setSettings.tracks[track.trackId]!.parts[part.id]!.areaOfInterest,
                    
                    dontDrawVisual: part.dontDrawVisual,
                    mapMaxIndex: part.mapMaxIndex,
                    allValues: part.allValues,
                    damperTarget: storeDamperTarget
                )
                storeParts.append(storePart)
            }
            
            var storeTrack = InstrumentsSet.Track(
                id: track.id,
                trackId: track.trackId,
                muted: track.muted,
                instrumentType: track.instrumentType,
                midiTargetTrackId: track.midiTargetTrackId,
                midiClipGroup: track.midiClipGroup,
                excludeLevelClipControl: track.excludeLevelClipControl,
                startType: track.startType,
                masterTrackId: track.midiTargetTrackId,
                instrumentName: track.instrumentName,
                
                instrumentColor: setSettings.tracks[track.trackId]!.instrumentColor,
                volume: setSettings.tracks[track.trackId]!.instrumentVolume,
                
                midiFiles: track.midiFiles,
                midiThreshold: track.midiThreshold,
                exsFiles: track.exsFiles,
                audioFiles: track.audioFiles,
                effects: track.effects,
                parts: storeParts,
                
                levels: setSettings.tracks[track.trackId]!.levels,
                
                scoreWalkDuration: track.scoreWalkDuration
            )
            storeTracks.append(storeTrack)
            
            //Duplicate last track
            if duplicateLastTrack && track.trackId == instrumentSet.tracks.last!.trackId {
                storeTrack.trackId = storeTrack.trackId+"2"
                storeTrack.id = storeTrack.id+"2"
                storeTrack.instrumentName = storeTrack.instrumentName+"(2)"
                let storePartsIndex = storeParts.enumerated()
                for (index, _) in storePartsIndex {
                    storeTrack.parts[index].damperTarget.trackId = storeTrack.id
                }
                let duplicateTrack = storeTrack
                storeTracks.append(duplicateTrack)
            }
        }
        
        let storeInstrumentSet = InstrumentsSet(
            name: instrumentSet.name,
            filesPath: instrumentSet.filesPath,
            bpm: instrumentSet.bpm,
            timeSignature: instrumentSet.timeSignature,
            
            //MasterTrack effects editor values
            masterTrackEffects: modifiedMasterEffects,
            
            rows: instrumentSet.rows,
            columns: instrumentSet.columns,
            levelDurations: instrumentSet.levelDurations,
            levelInstruments: instrumentSet.levelInstruments,
            levelClipControl: instrumentSet.levelClipControl,
            levelClipControlStartLevel: instrumentSet.levelClipControlStartLevel,
            playViewImages: instrumentSet.playViewImages,
            tracks: storeTracks
        )
            
        return storeInstrumentSet
    }
    
    static func setSessionSetting() -> SessionSettings {
        
        let storeSessionSettings = StoreSessionSettings.readSessionSettings(fileName: "SeM-settings")
        
        print("setSessionSetting storeSessionSettings.imageMax \(storeSessionSettings.imageMax)")
        
        let sessionSetting = SessionSettings(
            imageMax: storeSessionSettings.imageMax,
            imageMaxStepSizeLight: 5,
            imageMaxStepAmountLight: 5,
            imageMaxLightPart: storeSessionSettings.imageMaxLightPart,
            imageFeedback: storeSessionSettings.imageFeedback,
            imageFeedbackDisctancePart: storeSessionSettings.imageFeedback,
            calibrationPartMeterSteps: 12
        )
        
        return sessionSetting
    }
    
    static func createSessionFile(
        imageMax: Int, imageMaxLightPart: Int, imageFeedback: Float
    ){
        let fileName: String = "SeM-settings"
        let storeSettings = StoreSessionSettings(
            imageMax: imageMax,
            imageMaxLightPart: imageMaxLightPart,
            imageFeedback: imageFeedback
        )
        
        StoreSessionSettings.writeSessionSettings(fileName: fileName, storeSessionSettings: storeSettings)
    }
    
    static func getPartColors( trackColor: Color, areaOfInterest: [Int]) -> [Color]{
        
        var areaOfInterestColor: [Color] = []
        for i in areaOfInterest {
            if i == 1 { areaOfInterestColor.append(trackColor) }
            else { areaOfInterestColor.append(.black.opacity(0.01)) }
        }
        return areaOfInterestColor
    }
    
    static func getIndexes(areaOfInterest: [Int]) -> [Int] {
        return areaOfInterest.enumerated().compactMap { $0.element == 1 ? $0.offset : nil }
    }
    
    static func setSettings(instrumentSet: InstrumentsSet) -> SetSettings {
        
        let masterEffects: OrderedDictionary<Int,MasterTrackEffectsSettings> = masterTrackSettings(instrumentSet: instrumentSet)
        
        var tracks: OrderedDictionary<String,TrackSettings> = [:]
        let tracksLoaded = instrumentSet.tracks
        //Keep track of partNumber for variations track/instrument Color...
        var partNumber: Int = 0
        for trackLoaded in tracksLoaded {
            
            partNumber = 0
            var parts: OrderedDictionary<String, PartSettings> = [:]
            for partLoaded in trackLoaded.parts {
                
                let part = PartSettings(
                    partId: partLoaded.id,
                    partName: partLoaded.instrumentPartName,
                    partNumber: partNumber,
                    rampUp: partLoaded.damperTarget.nodeSettings!.rampSpeed!,
                    rampDown: partLoaded.damperTarget.nodeSettings!.rampSpeedDown!,
                    areaOfInterest: partLoaded.areaOfInterest,
                    areaOfInterestColor: self.getPartColors(trackColor: trackLoaded.instrumentColor, areaOfInterest: partLoaded.areaOfInterest),
                    dontDrawVisual: partLoaded.dontDrawVisual ?? false
                )
                parts[partLoaded.id] = part
                partNumber += 1
            }
            
            let track = TrackSettings(
                trackId: trackLoaded.id,
                trackName: trackLoaded.instrumentName,
                instrumentVolume: trackLoaded.volume,
                instrumentColor: trackLoaded.instrumentColor,
                levels: trackLoaded.levels,
                parts: parts)
            
            tracks[trackLoaded.id] = track
        }
        let setSettings = SetSettings(
            setName: instrumentSet.name,
            rows: instrumentSet.rows,
            columns: instrumentSet.columns,
            masterEffects: masterEffects,
            tracks: tracks
        )
        
        return setSettings
    }
    
    //Create the "database" to store the changed values in the master track, these values will be written to disk
    static func masterTrackSettings(instrumentSet: InstrumentsSet) -> OrderedDictionary<Int,MasterTrackEffectsSettings> {
        
        var masterTrackSettings: OrderedDictionary<Int,MasterTrackEffectsSettings> = [:]
        let loadedEffects = instrumentSet.masterTrackEffects
        var effectIndex: Int = 0
        for loadedEffect in loadedEffects {
            
            //Store parameter setting in:
            var parameters: OrderedDictionary<Int,ParameterSettings> = [:]
            
            //Get array of vars for selected effect
            let parametersStrings = loadedEffect.effectVars(effectType: loadedEffect.effectType)
            var parameterIndex: Int = 0
            for parameterString in parametersStrings {
                
                let valueAndRanges = loadedEffect.valueAndRanges(parameter: parameterString)
                
                let parameterSetting = ParameterSettings(
                    index: parameterIndex,
                    name: parameterString,
                    value: Double(valueAndRanges!.value),
                    range: valueAndRanges!.range
                )
                
                parameters[parameterIndex] = parameterSetting
                parameterIndex += 1
            }
            
            let masterTrackSetting = MasterTrackEffectsSettings(
                index: effectIndex,
                name: loadedEffect.effectType.rawValue,
                parameters: parameters
            )
            masterTrackSettings[effectIndex] = masterTrackSetting
            effectIndex += 1
        }
        
        return masterTrackSettings
    }
    
    //Create the object to build the master track view. This cannot hold changed values due to View rebuild on change
    static func masterTrackViewObject(instrumentSet: InstrumentsSet, setSettings: SetSettings) -> [MasterTrackEffect] {
        
        let masterEffects = instrumentSet.masterTrackEffects
        
        var masterTrackViewObject: [MasterTrackEffect] = []
        
        for (effectIndex, effect) in masterEffects.enumerated() {
            
            var parameters: [Parameter] = []
            
            let parametersString = effect.effectVars(effectType: effect.effectType)
            
            for (parameterIndex, parameterString) in parametersString.enumerated() {
                
                //Here we need to get the value from the
                let value = setSettings.masterEffects[effectIndex]!.parameters[parameterIndex]!.value
                let range = setSettings.masterEffects[effectIndex]!.parameters[parameterIndex]!.range
                
                //Here are we getting the value from the effect?
                let parameter = Parameter(
                    name: parameterString,
                    value: value,
                    range: range
                )
                
                parameters.append(parameter)
            }
            let masterTrackEffect = MasterTrackEffect(
                effectName: effect.effectType.rawValue,
                parameters: parameters
            )
            masterTrackViewObject.append(masterTrackEffect)
        }
        return masterTrackViewObject
    }
    
    //This last object keeps track of the same master track values to hold localy in a @State var
    static func masterTrackStateObject(viewObject: [MasterTrackEffect]) -> [[Float]] {
        
        //   Replaces  @State var masterEffect: [[Float]] = [
        //        [0,0,0,0,0,0,0,0,0,0],
        //        [0,0,0,0,0,0,0,0,0,0],
        //        [0,0,0,0,0,0,0,0,0,0]
        
        var parametersPerEffect: [[Float]] {
            var array: [[Float]] = []
            if let max = viewObject.map(\.parameters!.count).max(by: { $0 < $1 }) {
                for _ in viewObject {
                    array.append(Array(repeating: 0.0, count: max))
                }
            }
            return array
        }
        
        return parametersPerEffect
    }
}
