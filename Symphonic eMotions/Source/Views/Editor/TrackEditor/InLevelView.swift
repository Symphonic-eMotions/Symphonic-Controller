//
//  InLevelView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 10/04/2023.
//

import SwiftUI

struct InLevelView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    // This is a 1 track View
    var trackId: String

    @Binding var showEditorPart: EditorParts
    @Binding var trackLevels: [String: [Int]]

    @State var tLevels: [Int]

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showEditorPart: Binding<EditorParts>,
        trackLevels: Binding<[String: [Int]]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showEditorPart = showEditorPart
        _trackLevels = trackLevels

        // Initialize tLevels with value from trackLevels[trackId]
        let levels = trackLevels.wrappedValue[trackId] ?? []
        _tLevels = State(initialValue: levels)
    }

    let columnWidth: CGFloat = 150
    let color: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            // Levels
            HStack {
                ZStack {
                    Rectangle()
                        .frame(width: 80, height: 35)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.primary))
                        .background(showEditorPart == .levels ? .clear : color)

                    Text("Levels")
                        .frame(width: 80, height: 35)
                }
                .frame(width: columnWidth, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        showEditorPart = .levels
                    }
                }

                ForEach(0 ..< (setInfoModel.setSettings.levels.count + 1), id: \.self) { level in
                    // This should be based of a @State
                    let inLevel: Bool = (tLevels.contains(level) == true)

                    ZStack {
                        Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(level == setInfoModel.setSettings.levels.count ? .red : .white, lineWidth: 3))
                            .background(inLevel ? color : .clear)

                        Text("\(level + 1)")
                            .foregroundColor(inLevel ? .white : .gray)
                    }
                    .onTapGesture {
                        // Local state
                        if self.tLevels.contains(level) {
                            self.tLevels.removeAll { $0 == level }
                        } else {
                            self.tLevels.append(level)
                        }
                        // Store to disk
                        currentTrack.levels = tLevels
                        // Let binding know
                        trackLevels[trackId] = tLevels
                    }
                }
            }
        }
        .padding(.leading)
        .onAppear {
            // Ensure currentLevels is updated whenever the View appears
            tLevels = currentTrack.levels
        }
    }
}
