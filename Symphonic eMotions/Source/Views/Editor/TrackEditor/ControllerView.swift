//
//  ControllerView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 09/07/2023.
//

import SwiftUI

struct ControllerView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    //Bindings
    @Binding var showEditorPart: EditorParts
    
    @Binding var dampMode: [String: InstrumentsSet.Track.Part.DamperTarget.DampMode]
    
    @Binding var targetTypes: [String: InstrumentsSet.Track.Part.DamperTarget.NodeType]
    @Binding var targetNames: [String: InstrumentsSet.Track.Effect.EffectType]
    @Binding var targetParameters: [String: String]
    @Binding var parametersInversed: [String: Bool]

    @State private var localTargetNames: [String: InstrumentsSet.Track.Effect.EffectType]
    @State private var localEffectTypes: [InstrumentsSet.Track.Effect.EffectType]
    @State private var localParametersEffect: [InstrumentsSet.Track.Effect.EffectKeys]
    @State private var localParametersSequencer: [String]
    @State private var localParametersInstrument: [String]
    
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        dampMode: Binding<[String: InstrumentsSet.Track.Part.DamperTarget.DampMode]>,
        
        targetTypes: Binding<[String: InstrumentsSet.Track.Part.DamperTarget.NodeType]>,
        targetNames: Binding<[String: InstrumentsSet.Track.Effect.EffectType]>,
        targetParameters: Binding<[String: String]>,
        parametersInversed: Binding<[String: Bool]>
    )  {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _dampMode = dampMode
        _targetTypes = targetTypes
        _targetNames = targetNames
        _targetParameters = targetParameters
        _parametersInversed = parametersInversed
        
        _localTargetNames = State(initialValue: targetNames.wrappedValue)
        _localEffectTypes = State(initialValue: InstrumentsSet.Track.Effect.EffectType.allCases)
        _localParametersEffect = State(initialValue: InstrumentsSet.Track.Effect.EffectKeys.allCases)
        _localParametersSequencer = State(initialValue: ["velocity"])
        _localParametersInstrument = State(initialValue: ["samplerCC9"])
        
    }
    
    let columnWidth: CGFloat = 150
    let buttonWidth: CGFloat = 220
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){

            Divider()

            HStack() {
                
                VStack {
                    
                    ZStack {
                        
                        Rectangle()
                            .frame(width: 130, height: 34)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background( showEditorPart == .controller ? .clear : color )
                        
                        Text("Controllers")
                            .frame(width: 130, height: 34)
                        
                    }
                    .frame(width: columnWidth, alignment: .leading)
                    .onTapGesture {
                        withAnimation {
                            showEditorPart = .controller
                        }
                    }
                }
                HStack(spacing: 20) {
                    
                    //We need to bound these to the partId's of this track
                    let partIds = currentTrack.parts.keys
                    
                    //Use the targetTypes to get the partIds from all tracks and filter on current track
                    ForEach(Array(targetTypes), id: \.0) { partId, targetType in
                        
                        if partIds.contains(partId) {
                            
                            VStack{
                                
                                Picker("Controller type", selection: bindingTargetTypes(partId)) {
                                    ForEach(InstrumentsSet.Track.Part.DamperTarget.NodeType.allCases, id: \.self) { type in
                                        Text(type.description).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 200, height: 50)
                                
                                
                                if targetType == .effect {
                                    
                                    //Effect Type controls actual effects in settings
                                    Picker("Effect type", selection: bindingTargetNames(partId)) {
                                        ForEach(localEffectTypes, id: \.self) { type in
                                            Text(type.description).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 200, height: 50)
                                    
                                    Picker("Effect parameter", selection: bindingEffectParameter(partId)) {
                                        ForEach(filteredParameterEffect(partId: partId), id: \.self) { type in
                                            Text(type.description).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 200, height: 50)
                                    
                                    //Inverse parameter during play
                                    Toggle(isOn: bindingForInversionParameter(partId)){
                                        Text("Inversed")
                                    }
                                    .frame(width: 200, height: 50)
                                }
                                else if targetType == .instrument {
                                    
                                    Picker("Instrument parameter", selection: bindingInstrumentParameter(partId)) {
                                        ForEach(localParametersInstrument, id: \.self) { type in
                                            //Text(type.humanReadable).tag(type)
                                            Text(type.description).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 200, height: 50)
                                }
                                else if targetType == .sequencer {
                                    
                                    Picker("Sequencer parameter", selection: bindingSequencerParameter(partId)) {
                                        ForEach(localParametersSequencer, id: \.self) { type in
                                            //Text(type.humanReadable).tag(type)
                                            Text(type.description).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 200, height: 50)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading)
        .onAppear {
            updateTargetType()
            updateTargetNames()
            updateTargetParameter()
        }
    }
    
    //Store controller type
    private func bindingTargetTypes(_ key: String) -> Binding<InstrumentsSet.Track.Part.DamperTarget.NodeType> {
        Binding(
            get: {
                targetTypes[key] ?? .effect
            },
            set: { newValue in
                targetTypes[key] = newValue
                currentTrack.parts[key]?.targetType = newValue
            }
        )
    }
    
    //Store effect type and update effect parameter picker
    private func bindingTargetNames(_ key: String) -> Binding<InstrumentsSet.Track.Effect.EffectType> {
        Binding(
            get: {
                targetNames[key] ?? .none
            },
            set: { newValue in
                
                targetNames[key] = newValue
                currentTrack.parts[key]?.targetNameEffect = newValue
                localParametersEffect = filteredParameterEffect(partId: key)
                
                // find the key in currentTrack.effects corresponding to newValue
                if let foundKey = findKeyForValue(value: newValue) {
                    //We need to do nothing, effect is already there to control
                    print("Effect allready in chain \(newValue) at key \(foundKey) in currentTrack.effects")
                    
                } else {
                    
                    let highestKey = currentTrack.effects.keys.max() ?? 0
                    let nextKey = highestKey + 1
                    
                    //Add effect to effects
                    let newEffect = TrackEffectsHelper.newTrackEffectSetting(
                        effectType: newValue,
                        key: nextKey
                    )
                    
                    currentTrack.effects[nextKey] = newEffect
                    
                    print("EFFECT ADDED \(newValue.rawValue)")
                }
            }
        )
    }
    
    //Store effect parameter
    private func bindingEffectParameter(_ key: String) -> Binding<InstrumentsSet.Track.Effect.EffectKeys> {
        Binding(
            get: {
                guard let rawValue = targetParameters[key] else {
                    return .effectType // Return a default value if the rawValue is not found
                }
                return InstrumentsSet.Track.Effect.EffectKeys(rawValue: rawValue) ?? .effectType
            },
            set: { newValue in
                targetParameters[key] = newValue.rawValue
                currentTrack.parts[key]?.targetParameterEffect = newValue
            }
        )
    }
    
    //Store instrument parameter
    private func bindingInstrumentParameter(_ key: String) -> Binding<String> {
        Binding(
            get: {
                guard let rawValue = targetParameters[key] else {
                    return localParametersInstrument.first!
                }
                return rawValue
            },
            set: { newValue in
                targetParameters[key] = newValue
                currentTrack.parts[key]?.targetParameterInstrument = newValue
            }
        )
    }
    
    //Store sequencer parameter
    private func bindingSequencerParameter(_ key: String) -> Binding<String> {
        Binding(
            get: {
                guard let rawValue = targetParameters[key] else {
                    return localParametersSequencer.first!
                }
                return rawValue
            },
            set: { newValue in
                targetParameters[key] = newValue
                currentTrack.parts[key]?.targetParameterSequencer = newValue
            }
        )
    }
    
    func bindingForInversionParameter(_ key: String) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                parametersInversed[key, default: false]
            },
            set: { newValue in
                parametersInversed[key] = newValue
                currentTrack.parts[key]?.parametersInversed = newValue
            }
        )
    }
    
    //Set controller type picker
    private func updateTargetType() {
        targetTypes = [:]
        for track in setInfoModel.setSettings.tracks {
            for part in track.value.parts {
                targetTypes[part.value.partId] = part.value.damperTarget.nodeType
            }
        }
    }
    
    //Set effect type picker
    private func updateTargetNames() {
        targetNames = [:]
        for track in setInfoModel.setSettings.tracks {
            for part in track.value.parts {
                // Use part.key instead of part.value.partId
                targetNames[part.key] = InstrumentsSet.Track.Effect.EffectType(rawValue: part.value.damperTarget.nodeName) ?? InstrumentsSet.Track.Effect.EffectType.none
            }
        }
    }
    
    //Set parameter type effetcs picker
    private func updateTargetParameter() {
        targetParameters = [:]
        for track in setInfoModel.setSettings.tracks {
            for part in track.value.parts {
                targetParameters[part.key] = String(part.value.damperTarget.parameter)
            }
        }
        
    }
    
    //Only show parameters with selected effect type
    private func filteredParameterEffect(partId: String) -> [InstrumentsSet.Track.Effect.EffectKeys] {
        
        let trackEffect = InstrumentsSet.Track.Effect()
        let selectedEffectType = targetNames[partId]
        
        return trackEffect.effectVars(effectType: selectedEffectType!)
    }
    
    private func findKeyForValue(value: InstrumentsSet.Track.Effect.EffectType) -> Int? {
        for (key, effect) in currentTrack.effects {
            if effect.effectType == value {
                return key
            }
        }
        return nil
    }
    
//    func removeTargetNameEffect(at key: String, effectKey: Int) {
//        // Check if the part exists for the given key
//        guard let part = currentTrack.parts[key] else {
//            print("No part found for key: \(key)")
//            return
//        }
//
//        // Check if the effect exists for the given effectKey
//        guard currentTrack.effects.keys.contains(effectKey) else {
//            print("No effect found for key: \(effectKey)")
//            return
//        }
//
//        // Set the targetNameEffect to none
////        part.targetNameEffect = .none
//
//        // Remove the effect from the effects dictionary
//        currentTrack.effects.remove(at: effectKey)
//    }
}
