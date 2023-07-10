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
    @Binding var targetType: [String: InstrumentsSet.Track.Part.DamperTarget.NodeType]
    @Binding var targetNameEffect: [String: InstrumentsSet.Track.Effect.EffectType]
    @Binding var targetParameterEffect: [String: InstrumentsSet.Track.Effect.EffectKeys]
//    @Binding var targetParameterSequencer: [String: String]
//    @Binding var targetParameterInstrument: [String: String]
    
    @State private var selectedEffectType: InstrumentsSet.Track.Effect.EffectType? = .lowPassFilter
    @State private var selectedEffectParameter: InstrumentsSet.Track.Effect.EffectKeys? = .effectType
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        dampMode: Binding<[String: InstrumentsSet.Track.Part.DamperTarget.DampMode]>,
        targetType: Binding<[String: InstrumentsSet.Track.Part.DamperTarget.NodeType]>,
        targetNameEffect: Binding<[String: InstrumentsSet.Track.Effect.EffectType]>,
        targetParameterEffect: Binding<[String: InstrumentsSet.Track.Effect.EffectKeys]>
    )  {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _dampMode = dampMode
        _targetType = targetType
        _targetNameEffect = targetNameEffect
        _targetParameterEffect = targetParameterEffect
    }
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){

            Divider()

            HStack() {

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
                
                HStack(spacing: 20) {
                    
                    ForEach(Array(currentTrack.parts.enumerated()), id: \.offset ){ index, part in
                        
                        //Part parameters above each other
                        VStack {
                            
                            //Controller type Sequencer, Instrument or Effect
                            let excludedCases: [InstrumentsSet.Track.Part.DamperTarget.NodeType] = [.master]
                            Picker("Controller type", selection: Binding(
                                get: {
                                    targetType[part.value.partId] ?? excludedCases.first ?? .effect
                                },
                                set: { newValue in
                                    DispatchQueue.main.async {
                                        targetType[part.value.partId] = newValue
                                    }
                                }
                            )
                            ) {
                                ForEach(InstrumentsSet.Track.Part.DamperTarget.NodeType.allCases.filter { !excludedCases.contains($0) }, id: \.self) { type in
                                    Text(type.description)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 300, height: 50)
                            
                            
                            if targetType[part.value.partId] == .effect {
                                
                                VStack {
                                    
                                    Picker("Effect name", selection: Binding(
                                        get: { self.selectedEffectType ?? .lowPassFilter },
                                        set: {
                                            self.selectedEffectType = $0
                                            self.targetNameEffect[part.value.partId] = $0
                                        }
                                    )) {
                                        ForEach(Array(InstrumentsSet.Track.Effect.EffectType.allCases), id: \.self) { type in
                                            let effectName: String = type.rawValue
                                            Text(effectName.capitalized).tag(type)
                                        }
                                    }
                                    
                                    let effectParameters = InstrumentsSet.Track.Effect.effectVars(effectType: self.selectedEffectType!)
//                                    Picker("Effect Parameter", selection: Binding(
//                                        get: {
//                                            selectedEffectParameter ?? effectParameters.first
//                                            $targetParameterEffect[part.value.partId]
//                                        },
//                                        set: { newValue in
//                                            selectedEffectParameter = newValue
//                                        }
//                                    )) {
//                                        ForEach(effectParameters, id: \.self) { parameter in
//                                            let parameterName: String = parameter.rawValue
//                                            Text(parameterName.capitalized).tag(parameter)
//                                        }
//                                    }
//                                    .pickerStyle(.menu)
//                                    .frame(width: 300, height: 50)
                                }
                            }
                            
                            if targetType[part.value.partId] == .sequencer {
                                
                                Text("Parameter sequencer")
                            }
                            
                            if targetType[part.value.partId] == .instrument {
                                
                                Text("Parameter instrument")
                            }
                            
                            Divider()
                            
                            HStack{
                                Text("Parameter range")
                                
                                let parameterRangeString = part.value.damperTarget.parameterRange.map { String($0) }.joined(separator: ", ")
                                Text(parameterRangeString)
                            }
                            HStack{
                                Text("Damp mode")
                                Text(part.value.damperTarget.dampMode?.rawValue ?? "No damp mode")
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
