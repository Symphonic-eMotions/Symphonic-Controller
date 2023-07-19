//
//  TrackEffectsHelper.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/07/2023.
//

import Foundation
import OrderedCollections

class TrackEffectsHelper {
 
    //Create the "database" to store the changed values in the track, these values will be written to disk
    static func trackEfectsSettings(
        track: InstrumentsSet.Track
    ) -> OrderedDictionary<Int,TrackEffectsSettings> {
        
        var trackEffectsSettings: OrderedDictionary<Int,TrackEffectsSettings> = [:]
        track.effects?.enumerated().forEach { effectIndex, loadedEffect in
            
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
            
            let trackEffectSetting = TrackEffectsSettings(
                index: effectIndex,
                name: loadedEffect.effectType.description,
                effectType: loadedEffect.effectType,
                parameters: parameters
            )
            trackEffectsSettings[effectIndex] = trackEffectSetting
        }
        
        return trackEffectsSettings
    }
    
    //Create the object to build the master track view. This cannot hold changed values due to View rebuild on change
    static func trackEffectViewObject(
        trackSettings: TrackSettings
    ) -> [TrackEffect] {
        
        var trackEffectsViewObject: [TrackEffect] = []
        
        trackSettings.effects.enumerated().forEach { effectIndex, effect in
            
            var parameters: [Parameter] = []
            
            let ite = InstrumentsSet.Track.Effect()
            let parametersString = ite.effectVars(effectType: effect.value.effectType)
            
            for (parameterIndex, parameterString) in parametersString.enumerated() {
                
                //TODO: Here we need to get the track effect values
                let value = trackSettings.effects[effectIndex]!.parameters[parameterIndex]!.value
                let range = trackSettings.effects[effectIndex]!.parameters[parameterIndex]!.range

                //Here are we getting the value from the effect?
                let parameter = Parameter(
                    name: parameterString.description,
                    value: value,
                    range: range
                )

                parameters.append(parameter)
            }
            let trackEffect = TrackEffect(
                effectName: effect.value.effectType.description,
                parameters: parameters
            )
            trackEffectsViewObject.append(trackEffect)
        }
        return trackEffectsViewObject
    }
    
    //This last object keeps track of the same master track values to hold localy in a @State var
    static func trackEffectsStateObject(viewObject: [TrackEffect]) -> [[Float]] {
        
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
