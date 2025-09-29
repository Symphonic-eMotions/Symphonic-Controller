//
//  NoteNumberLevelView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2023.
//

import SwiftUI

struct NoteNumberLevelView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    // This is a 1 track View
    @State var trackId: String

    // Binding
    // trackLevels is this track in this level [0,3] == track is in the first and fourth lvel
    @Binding var trackLevels: [String: [Int]]
    // This will be the clip number for a level
    // noteNumbersLevels has the generated sequence index within noteNumbersClips
    @Binding var noteNumbersLevels: [String: [Int]]
    // noteNumbersClips correlation between audio files (A,B,C) and its clip number
    // This is what we cycle in NoteNumberLevelView
    @Binding var noteNumbersClips: [String: [Int]]

    @State var nnLevels: [Int]

    let columnWidth: CGFloat = 150

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        trackLevels: Binding<[String: [Int]]>,
        noteNumbersLevels: Binding<[String: [Int]]>,
        noteNumbersClips: Binding<[String: [Int]]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        _trackId = State(initialValue: trackId)
        _trackLevels = trackLevels
        _noteNumbersLevels = noteNumbersLevels
        _noteNumbersClips = noteNumbersClips

        // We initialize nnLevels with value from noteNumbersLevels[trackId]
        let levels = noteNumbersLevels.wrappedValue[trackId] ?? []
        _nnLevels = State(initialValue: levels)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Divider()

            HStack {
                Text("Place note in level: ")
                    .frame(width: columnWidth, alignment: .leading)

                // Replace note numbers with midi clip
                // TODO: Name Samples ABC

//                Text("\($trackLevels.wrappedValue.description)")
//                Text("\($noteNumbersLevels.wrappedValue.description)")
//                Text("\($noteNumbersClips.wrappedValue.description)")

                // Loop over levels
                ForEach(0 ..< setInfoModel.setSettings.levels.count, id: \.self) { level in
                    // Show button per level
                    VStack {
                        // Show level number
                        let levelNumber = level + 1
                        Text("\(levelNumber)")
                            .foregroundColor(.blue)

                        // Make increment button to select note number midi clip
                        ZStack {
                            // noteNumbersLevels has active levels [1,6]
                            let clipNumber = noteNumbersLevels[trackId]?[level] ?? 0

//                            let clipNumber = [trackId]![level]
                            let clipLetter: String = AppUtils.letterForNumber(clipNumber) ?? "-"

                            Rectangle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))

                            Text("\(clipLetter)")
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            let increment = noteNumbersLevels[trackId]![level] + 1
                            let incrementModulo = increment % noteNumbersClips[trackId]!.count

                            print("clipLetters Midi Files \(noteNumbersClips[trackId]!.map(String.init).joined(separator: ", ")) level \(level) updated with \(increment) % \(noteNumbersClips[trackId]!.count) = \(incrementModulo)")
                            // Store
                            currentTrack.notesToLevel[level] = incrementModulo
                            // Binding
                            noteNumbersLevels[trackId]![level] = incrementModulo
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
