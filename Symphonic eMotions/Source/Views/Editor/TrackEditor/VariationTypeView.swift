//
//  VariationTypeView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 10/04/2023.
//

import SwiftUI

struct VariationTypeView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    // This is a 1 track View
    var trackId: String

    // Binding
    @Binding var showEditorPart: EditorParts
    @Binding var noteSources: [String: NoteSource]
    @Binding var variationTypes: [String: VariationType]
    @Binding var availableVariationTypes: [String: [VariationType]]

    // State
    @State var variationType: VariationType
    @State var availableVariationTypesLocal: [VariationType]

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        noteSources: Binding<[String: NoteSource]>,
        variationTypes: Binding<[String: VariationType]>,
        availableVariationTypes: Binding<[String: [VariationType]]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _noteSources = noteSources
        _variationTypes = variationTypes
        _variationType = State(
            initialValue: variationTypes[trackId].wrappedValue!
        )
        _availableVariationTypes = availableVariationTypes
        _availableVariationTypesLocal = State(
            initialValue: availableVariationTypes[trackId].wrappedValue!
        )
    }

    let columnWidth: CGFloat = 150
    let color: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            // Track is present in level
            HStack {
                ZStack {
                    Rectangle()
                        .frame(width: 130, height: 34)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        .background(showEditorPart == .sound ? .clear : color)

                    Text("Variation")
                        .frame(width: 130, height: 34)
                }
                .frame(width: columnWidth, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        showEditorPart = .variation
                    }
                }

                // Level, Position, sequencial
                Picker("Select track type", selection: $variationType) {
                    ForEach(availableVariationTypes[trackId]!, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: variationType) { type in
                    withAnimation {
                        // Store to file
                        currentTrack.variationType = type
                        // Tell parent
                        variationTypes[trackId] = type
                        // Keep local state
                        variationType = type
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
