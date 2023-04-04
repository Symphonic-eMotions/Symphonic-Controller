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
    
    
    static func documentDirectory() -> URL {
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      return documentsDirectory
    }
    
    //MARK: Sets
    static func loadSets(json: String) -> Sets {
        
        guard let sets = Sets.withJSON(json) else {
            preconditionFailure()
        }
        return sets
    }
    
    //MARK: Instrument Set Loading
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
    
    //MARK: Write Instrument Set
    //Write set settings to file structure and return used file name
    static func createWorkingFile(
        setSettings: SetSettings,
        instrumentSet: InstrumentsSet,
        duplicateLastTrack: Bool,
        asNewFile: Bool
    ) -> String {
        
        var fileName: String!
        
        //Write over last opened file.
        if !asNewFile {
            let deleteExtension = setSettings.setURL.deletingPathExtension()
            fileName = deleteExtension.lastPathComponent
        }
        //New file name
        else{
            let setName = instrumentSet.name
            let timestammp = NSDate().timeIntervalSince1970
            fileName = setName + "-timestamp-\(timestammp)"
        }
        
        let storeInstrumentSet: InstrumentsSet = createInstrumentSet(setSettings: setSettings, instrumentSet: instrumentSet, duplicateLastTrack: duplicateLastTrack)
        
        InstrumentsSet.writeLoadedSet(setName: fileName, instrumentSet: storeInstrumentSet)
        
        return fileName
    }
    
    //Insrument set from current state
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
            
            let midiFiles = track.midiFiles
            var midiFile = midiFiles![0]
            midiFile.loopsToGrid.mapper = setSettings.tracks[track.trackId]?.loopsToGrid
            
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
                
                midiFiles: [midiFile],
                
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
            customName: setSettings.customName,
            filesPath: instrumentSet.filesPath,
            //BPM is changed by tempo buttons
            bpm: setSettings.bpm,
            hasTempo: instrumentSet.hasTempo,
            
            //MIGHT: change skin colors according to track colors
            //Bur what if skin colors difffer from skin colors?
            skin: setSettings.skins,
            
            timeSignature: instrumentSet.timeSignature,
            
            //MasterTrack effects editor values
            masterTrackEffects: modifiedMasterEffects,
            
            rows: setSettings.gridRows,
            columns: setSettings.gridColumns,
            levelSpeed: setSettings.levelSpeed,
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
        
        let readSessionSettings = ManageSessionSettings.readSessionSettings(fileName: "SeM-settings")
        
        let sessionSetting = SessionSettings(
            sensitivity: readSessionSettings.sensitivity,
            setURL: readSessionSettings.setURL ?? URL("setSessionSetting.json")
        )
        
        return sessionSetting
    }
    
    static func createSessionFile(sensitivity: Float, setURL: URL){
        
        let fileName: String = "SeM-settings"
        var localSensitifity: Float = 0
        
        //When loading a set we do not have the sensitifity present, so we load it from disk
        if sensitivity == -1 {
            //Load current sensitivity before writing
            let readSessionSettings = ManageSessionSettings.readSessionSettings(fileName: fileName)
            localSensitifity = readSessionSettings.sensitivity
        }
        else{
            localSensitifity = sensitivity;
        }
        
        
        print("Create session file with URL: \(setURL)")
        
        let storeSettings = ManageSessionSettings(
            sensitivity: localSensitifity,
            setURL: setURL
        )
        
        ManageSessionSettings.writeSessionSettings(fileName: fileName, storeSessionSettings: storeSettings)
    }
    
    //MARK: After load set instruction make this setting database for reference and saving
    static func setSettings(
        instrumentSet: InstrumentsSet,
        sessionSettings: SessionSettings
    ) -> SetSettings {
        
        let masterEffects: OrderedDictionary<Int,MasterTrackEffectsSettings> = masterTrackSettings(instrumentSet: instrumentSet)
        
        let skin: InstrumentsSet.Skin = instrumentSet.skin
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
                    //This needs to get the newly generated area of interest
//                    areaOfIntersetBoostFactor: self.getPartAreaBoostFactor(
//                        rows: instrumentSet.rows,
//                        columns: instrumentSet.columns,
//                        areaOfInterest: partLoaded.areaOfInterest
//                    ),
                    areaOfInterestColor: self.getPartColors(trackColor: trackLoaded.instrumentColor, areaOfInterest: partLoaded.areaOfInterest),
                    dontDrawVisual: partLoaded.dontDrawVisual ?? false
                )
                parts[partLoaded.id] = part
                partNumber += 1
            }
            
            var loopsToGrid: [Int] = trackLoaded.midiFiles?.first?.loopsToGrid.mapper ?? []
            if loopsToGrid.count == 0 {
                let grids = Grids(rows: instrumentSet.rows)
                loopsToGrid = grids!.oneClip
            }
            
            let track = TrackSettings(
                trackId: trackLoaded.id,
                trackName: trackLoaded.instrumentName,
                instrumentVolume: trackLoaded.volume,
                instrumentColor: trackLoaded.instrumentColor,
                loopsToGrid: loopsToGrid,
                levels: trackLoaded.levels,
                parts: parts)
            
            tracks[trackLoaded.id] = track
        }
        let setSettings = SetSettings(
            setName: instrumentSet.name,
            customName: instrumentSet.customName,
            setURL: sessionSettings.setURL,
            rows: instrumentSet.rows,
            columns: instrumentSet.columns,
            levelSpeed: instrumentSet.levelSpeed,
            levelInsrtuments: instrumentSet.levelInstruments,
            bpm: instrumentSet.bpm,
            masterEffects: masterEffects,
            tracks: tracks,
            skins: skin
        )
        
        return setSettings
    }
    
    //Not yet used for amplifying top row
    static func getPartAreaBoostFactor(
        rows: Int,
        columns: Int,
        areaOfInterest:[Int]
    ) -> [Int] {
        
        var deltaTimes:[Int] = []
        
        let twoRows:[Int]   = [400,0]
        let threeRows:[Int] = [400,200,0]
        let fourRows:[Int]  = [500,350,200,0]
        let fiveRows:[Int]  = [600,450,300,150,0]
        
        let twoXtwo:[Int] = [
            twoRows[0],twoRows[0],
            twoRows[1],twoRows[1]
        ]
        
        let threeXthree:[Int] = [
            threeRows[0],threeRows[0],threeRows[0],
            threeRows[1],threeRows[1],threeRows[1],
            threeRows[2],threeRows[2],threeRows[2]
        ]
        
        let fourXfour:[Int] = [
            fourRows[0],fourRows[0],fourRows[0],fourRows[0],
            fourRows[1],fourRows[1],fourRows[1],fourRows[1],
            fourRows[2],fourRows[2],fourRows[2],fourRows[2],
            fourRows[3],fourRows[3],fourRows[3],fourRows[3]
        ]
        
        let fiveXfive:[Int] = [
            fiveRows[0],fiveRows[0],fiveRows[0],fiveRows[0],
            fiveRows[1],fiveRows[1],fiveRows[1],fiveRows[1],
            fiveRows[2],fiveRows[2],fiveRows[2],fiveRows[2],
            fiveRows[3],fiveRows[3],fiveRows[3],fiveRows[3],
            fiveRows[4],fiveRows[4],fiveRows[4],fiveRows[4]
        ]
        
        for (index,value) in areaOfInterest.enumerated() {
            if value == 1 {
                if rows == 2{
                    deltaTimes.append(twoXtwo[index])
                }
                else if rows == 3 {
                    deltaTimes.append(threeXthree[index])
                }
                else if rows == 4 {
                    deltaTimes.append(fourXfour[index])
                }
                else if rows == 5 {
                    deltaTimes.append(fiveXfive[index])
                }
            }
        }
    
        return deltaTimes
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
    
    //Part editor SwiftUI interface
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
