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
    
//    @Binding var targetNameEffect: [String: InstrumentsSet.Track.Effect.EffectType]
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
        dampMode: Binding<[String: InstrumentsSet.Track.Part.DamperTarget.DampMode]>
        ,
        targetTypes: Binding<[String: InstrumentsSet.Track.Part.DamperTarget.NodeType]>
//        ,
//        targetNameEffect: Binding<[String: InstrumentsSet.Track.Effect.EffectType]>,
//        targetParameterEffect: Binding<[String: InstrumentsSet.Track.Effect.EffectKeys]>
    )  {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _dampMode = dampMode
        _targetTypes = targetTypes
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
                    
                    ForEach(Array(targetTypes.keys), id: \.self) { key in
                        Picker("Controller type", selection: bindingForTrack(key)) {
                            ForEach(InstrumentsSet.Track.Part.DamperTarget.NodeType.allCases, id: \.self) { type in
                                Text(type.description).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 200, height: 50)
                    }
                }
            }
        }
        .padding(.leading)
        .onAppear {
            updateTargetType() // Call the function to initialize targetTypes
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
    
    private func bindingForTrack(_ key: String) -> Binding<InstrumentsSet.Track.Part.DamperTarget.NodeType> {
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
}
