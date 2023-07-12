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

    @State private var localTargetNames: [String: InstrumentsSet.Track.Effect.EffectType]
    @State private var localEffectTypes: [InstrumentsSet.Track.Effect.EffectType]

    
//    @Binding var targetParameterEffect: [String: InstrumentsSet.Track.Effect.EffectKeys]
//    @Binding var targetParameterSequencer: [String: String]
//    @Binding var targetParameterInstrument: [String: String]
    
//    @State private var targetType: [String: InstrumentsSet.Track.Part.DamperTarget.NodeType]
    
//    var targetType: Binding<InstrumentsSet.Track.Part.DamperTarget.NodeType>

    
//    @State private var selectedEffectType: [String: InstrumentsSet.Track.Effect.EffectType]
//    @State private var selectedEffectParameter: [String: InstrumentsSet.Track.Effect.EffectKeys]
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        dampMode: Binding<[String: InstrumentsSet.Track.Part.DamperTarget.DampMode]>,
        targetTypes: Binding<[String: InstrumentsSet.Track.Part.DamperTarget.NodeType]>,
        targetNames: Binding<[String: InstrumentsSet.Track.Effect.EffectType]>
//        ,
//        targetParameterEffect: Binding<[String: InstrumentsSet.Track.Effect.EffectKeys]>
    )  {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _dampMode = dampMode
        _targetTypes = targetTypes
        _targetNames = targetNames
        _localTargetNames = State(initialValue: targetNames.wrappedValue)
        _localEffectTypes = State(initialValue: InstrumentsSet.Track.Effect.EffectType.allCases)
    }
    
    let columnWidth: CGFloat = 150
    let buttonWidth: CGFloat = 220
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
                    
                    //Use the targetTypes to get the partIds from this track
                    ForEach(Array(targetTypes.keys), id: \.self) { partId in
                        
                        VStack{
                            
                            Picker("Controller type", selection: bindingTargetTypes(partId)) {
                                ForEach(InstrumentsSet.Track.Part.DamperTarget.NodeType.allCases, id: \.self) { type in
                                    Text(type.description).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 200, height: 50)
                            
                            
                            Picker("Effect name", selection: bindingTargetNames(partId)) {
                                ForEach(localEffectTypes, id: \.self) { type in
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
        .padding(.leading)
        .onAppear {
            updateTargetType()
            updateTargetNames()
        }
    }
    
    private func updateTargetType() {
        targetTypes = [:]
        for track in setInfoModel.setSettings.tracks {
            for part in track.value.parts {
                targetTypes[part.value.partId] = part.value.damperTarget.nodeType
            }
        }
    }
    
    
    private func updateTargetNames() {
        targetNames = [:]
        for track in setInfoModel.setSettings.tracks {
            for part in track.value.parts {
                print("TRACK ID: \(track.key), PART ID: \(part.key), NODE NAME: \(part.value.damperTarget.nodeName)")
                
                // Use part.key instead of part.value.partId
                targetNames[part.key] = InstrumentsSet.Track.Effect.EffectType(rawValue: part.value.damperTarget.nodeName) ?? InstrumentsSet.Track.Effect.EffectType.none
            }
        }
        
        print("TARGET NAMES:")
        print(targetNames)
    }
    
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
    
    private func bindingTargetNames(_ key: String) -> Binding<InstrumentsSet.Track.Effect.EffectType> {
        Binding(
            get: {
                targetNames[key] ?? .none
            },
            set: { newValue in
                targetNames[key] = newValue
                
                print("SETTING EFFEXTNAME TO: \(newValue) partid: \(key)")
                
                currentTrack.parts[key]?.targetNameEffect = newValue
            }
        )
    }
}
