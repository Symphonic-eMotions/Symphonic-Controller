//
//  NoteNumberPositionsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 13/04/2023.
//

import SwiftUI

struct NoteNumberPositionsView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    // This is a 1 track View
    @State var trackId: String

    @Binding var noteNumbers: [String: [Int]]
    @Binding var noteNumbersPositions: [String: [Int]]

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        noteNumbers: Binding<[String: [Int]]>,
        noteNumbersPositions: Binding<[String: [Int]]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _noteNumbers = noteNumbers
        _noteNumbersPositions = noteNumbersPositions
    }

    let columnWidth: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading) {
            Divider()

            HStack {
                Text("Place notes in grid:")
                    .frame(width: columnWidth, alignment: .leading)

                let gridRows: Int = setInfoModel.setSettings.gridRows
                let gridColumns: Int = setInfoModel.setSettings.gridColumns

                // Note number grid
                VStack(spacing: 0) {
                    let cellWidth = CGFloat(200 / gridColumns - 1)
                    ForEach(0 ..< gridRows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0 ..< gridColumns, id: \.self) { column in
                                // Current cell index
                                let cellIndex = row * gridColumns + column

                                // The cell buttons
                                ZStack {
                                    Rectangle()
                                        .frame(width: cellWidth, height: cellWidth)
                                        .foregroundColor(.blue)
                                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))

                                    let gridNote = noteNumbersPositions[trackId]![cellIndex]
                                    let noteName: String = AppUtils.midiNoteName(for: gridNote)

                                    Text("\(noteName)")
                                        .foregroundColor(.white)
                                }
                                .onTapGesture {
                                    // Loop through available notenumbers
                                    let currentValue = noteNumbersPositions[trackId]![cellIndex]
                                    if let noteIndex = noteNumbers[trackId]!.firstIndex(where: { $0 == currentValue }) {
                                        // Increment index
                                        var incrementNoteIndex = noteIndex + 1
                                        // If index is higher then count then index = 0
                                        if incrementNoteIndex >= noteNumbers[trackId]!.count {
                                            incrementNoteIndex = 0
                                        }

                                        currentTrack.notesToGrid[cellIndex] = noteNumbers[trackId]![incrementNoteIndex]
                                        noteNumbersPositions[trackId]![cellIndex] = noteNumbers[trackId]![incrementNoteIndex]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
