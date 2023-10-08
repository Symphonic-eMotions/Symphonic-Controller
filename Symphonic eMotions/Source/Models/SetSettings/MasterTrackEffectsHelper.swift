//
//  MasterTrackEffectsHelper.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/07/2023.
//

import Foundation
import OrderedCollections

class MasterTrackEffectsHelper {
    
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
                
                let valueAndRanges = loadedEffect.valueAndRanges(parameter: parameterString.rawValue)
                
                let parameterSetting = ParameterSettings(
                    index: parameterIndex,
                    name: parameterString.rawValue,
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
                    type: parameterString.rawValue, 
                    name: parameterString.rawValue,
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
