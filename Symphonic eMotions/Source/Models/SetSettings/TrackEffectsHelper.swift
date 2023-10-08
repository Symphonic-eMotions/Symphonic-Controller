//
//  TrackEffectsHelper.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/07/2023.
//

import Foundation
import OrderedCollections
import AudioKit

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
    
    static func trackEffectInstrumentsSet(trackSetttings: TrackSettings ) -> [InstrumentsSet.Track.Effect] {
        
        var trackEffects: [InstrumentsSet.Track.Effect] = []
        for effect in trackSetttings.effects {
            var params: [ValueAndRange] = []
            let paramDict = effect.value.parameters
            for p in paramDict {
                params.append(ValueAndRange(
                    value: AUValue(p.value.value),
                    range: p.value.range
                ))
            }
            
            let trackEffect = InstrumentsSet.Track.Effect(
                effectType: effect.value.effectType,
                parameters: params
            )
            trackEffects.append(trackEffect)
        }
        return trackEffects
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
                    type: parameterString.rawValue,
                    name: parameterString.description,
                    value: value,
                    range: range
                )

                parameters.append(parameter)
            }
            let trackEffect = TrackEffect(
                effectType: effect.value.effectType.rawValue,
                effectName: effect.value.effectType.description,
                parameters: parameters
            )
            trackEffectsViewObject.append(trackEffect)
        }
        return trackEffectsViewObject
    }
    
    static func newTrackEffect(effectType: InstrumentsSet.Track.Effect.EffectType) -> TrackEffect {
        
        let effectName = effectType.rawValue
        
        let ite = InstrumentsSet.Track.Effect()
        let parameterValues = ite.effectParameterValues(effectType: effectType)
        let parameterNames = ite.effectVars(effectType: effectType)
        
        var parameters: [Parameter] = []
        
        for (index, parameterValue) in parameterValues.enumerated() {
            let parameter = Parameter(
                type: parameterNames[index].rawValue, 
                name: parameterNames[index].rawValue,
                value: Double(parameterValue.value),
                range: parameterValue.range
            )
            parameters.append(parameter)
        }
        let trackEffect = TrackEffect(
            effectType: effectType.rawValue, 
            effectName: effectName,
            parameters: parameters
        )
        
        return trackEffect
    }
    
    static func newTrackEffectSetting(
        effectType: InstrumentsSet.Track.Effect.EffectType,
        key: Int
    ) -> TrackEffectsSettings {
        
        let effectName = effectType.rawValue
        
        let ite = InstrumentsSet.Track.Effect()
        let parameterValues = ite.effectParameterValues(effectType: effectType)
        let parameterNames = ite.effectVars(effectType: effectType)
        
        var parameters: OrderedDictionary<Int, ParameterSettings> = OrderedDictionary<Int, ParameterSettings>()
        
        for (index, parameterValue) in parameterValues.enumerated() {
            let parameter = ParameterSettings(
                index: index,
                name: parameterNames[index].rawValue,
                value: Double(parameterValue.value),
                range: parameterValue.range
            )
            parameters[index] = parameter
        }
        
        let tes = TrackEffectsSettings(
            index: key,
            name: effectName,
            effectType: effectType,
            parameters: parameters
        )
        
        return tes
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
