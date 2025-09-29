//
//  NoteNumberView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2023.
//

import SwiftUI

struct NoteNumberView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    // This is a 1 track View
    @State var trackId: String

    // Bindings
    @Binding var noteNumbers: [String: [Int]]
    @Binding var noteNumberLetters: [String: [Int]]
    @Binding var soundSources: [String: InstrumentsSet.Track.InstrumentType]

    // State
    @State var isPlaying: [Bool]

    let columnWidth: CGFloat = 150

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        noteNumbers: Binding<[String: [Int]]>,
        noteNumberLetters: Binding<[String: [Int]]>,
        soundSources: Binding<[String: InstrumentsSet.Track.InstrumentType]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _noteNumbers = noteNumbers
        _noteNumberLetters = noteNumberLetters
        _soundSources = soundSources

        _isPlaying = State(
            initialValue: Array(
                repeating: false,
                count: noteNumbers.wrappedValue[trackId]!.count
            )
        )
    }

    var body: some View {
        HStack {
            VStack {
                Text("Note numbers")
                    .frame(width: columnWidth, alignment: .leading)

                HStack {
                    // Remove note button
                    Button("-") {
                        if (noteNumbers.count) > 1 {
                            let oldLength: Int = noteNumbers[trackId]!.count - 1
                            let oldNote: Int = noteNumbers[trackId]![oldLength]
                            // Mutate in file databse
                            currentTrack.midiGroup.removeLast()
                            // Binding structure
                            noteNumberLetters[trackId]!.removeLast()
                            // Interface
                            noteNumbers[trackId]!.removeLast()
                            // Note number player
                            isPlaying.removeLast()

                            let newLength: Int = noteNumbers[trackId]!.count - 1
                            let newNote: Int = noteNumbers[trackId]![newLength]

                            // Replace note in level
                            for (i, n) in currentTrack.notesToLevel.enumerated() {
                                if n == oldNote {
                                    currentTrack.notesToLevel[i] = newNote
                                }
                            }
                            // Replace note in grid
                            for (i, n) in currentTrack.notesToGrid.enumerated() {
                                if n == oldNote {
                                    currentTrack.notesToGrid[i] = newNote
                                }
                            }
                        }
                    }
                    .disabled(noteNumbers[trackId]!.count == 1)
                    .font(.system(size: 45))

                    // Add note button
                    Button("+") {
                        let increment: Int = (currentTrack.midiGroup.last ?? 47) + 1
                        currentTrack.midiGroup.append(increment)
                        noteNumbers[trackId]!.append(increment)
                        isPlaying.append(false)
                        noteNumberLetters[trackId]!.append(increment)
                    }
                    .font(.system(size: 45))
                }
            }

            // Note number interface
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0 ..< noteNumbers[trackId]!.count, id: \.self) { index in
                        VStack {
//                            //Play stop current note
//                            Image(systemName: isPlaying[index] ? "pause.fill" : "play.fill")
//                                .foregroundColor(.white)
//                                .frame(width: 40, height: 30)
//                                .padding(.vertical, 5.0)
//                                .padding(.horizontal, 5.0)
//                                .background(Color.accentColor)
//                                .cornerRadius(5.0)
//                                .onTapGesture {
//
//                                    setInfoModel.conductor.playNoteNumberSingleTrack(
//                                        trackId: trackId,
//                                        soundSource: soundSources[trackId]!,
//                                        noteNumber: noteNumbers[trackId]![index],
//                                        noteOn: isPlaying[index])
//
//                                    isPlaying[index].toggle()
//                                }

                            HStack {
                                // Lower current note
                                Button("-") {
                                    // Stop if playing
                                    if isPlaying[index] {
                                        setInfoModel.conductor.playNoteNumberSingleTrack(
                                            trackId: trackId,
                                            soundSource: soundSources[trackId]!,
                                            noteNumber: noteNumbers[trackId]![index],
                                            noteOn: isPlaying[index]
                                        )
                                        isPlaying[index] = false
                                    }
                                    // Decrease note number up to number which not exists yet
                                    if noteNumbers[trackId]![index] > 0 {
                                        let oldNote = noteNumbers[trackId]![index]

                                        noteNumbers[trackId]![index] -= 1
                                        while currentTrack.midiGroup.contains(noteNumbers[trackId]![index]) {
                                            noteNumbers[trackId]![index] -= 1
                                        }
                                        // Store new value
                                        currentTrack.midiGroup[index] = noteNumbers[trackId]![index]

                                        // Replace note in level
                                        for (i, n) in currentTrack.notesToLevel.enumerated() {
                                            if n == oldNote {
                                                currentTrack.notesToLevel[i] = noteNumbers[trackId]![index]
                                            }
                                        }
                                        // Replace note in grid
                                        for (i, n) in currentTrack.notesToGrid.enumerated() {
                                            if n == oldNote {
                                                currentTrack.notesToGrid[i] = noteNumbers[trackId]![index]
                                            }
                                        }
                                        // Tell parent View
                                        for (i, n) in noteNumberLetters[trackId]!.enumerated() {
                                            if n == oldNote {
                                                noteNumberLetters[trackId]![i] = noteNumbers[trackId]![index]
                                            }
                                        }
                                    }
                                }
                                .font(.system(size: 45))
                                .disabled(noteNumbers[trackId]![index] == 1)
                                .padding(.leading)

                                Text(String(self.noteNumbers[trackId]![index]))
                                    .frame(width: 50)

                                // Increment current note
                                Button("+") {
                                    // Stop if playing
                                    if isPlaying[index] {
                                        setInfoModel.conductor.playNoteNumberSingleTrack(
                                            trackId: trackId,
                                            soundSource: soundSources[trackId]!,
                                            noteNumber: noteNumbers[trackId]![index],
                                            noteOn: isPlaying[index]
                                        )
                                        isPlaying[index] = false
                                    }
                                    // Increae note number up to number which not exists yet
                                    if noteNumbers[trackId]![index] < 127 {
                                        let oldNote = noteNumbers[trackId]![index]

                                        // No double note numbers alowed
                                        noteNumbers[trackId]![index] += 1
                                        while currentTrack.midiGroup.contains(noteNumbers[trackId]![index]) {
                                            noteNumbers[trackId]![index] += 1
                                        }
                                        // Store new value
                                        currentTrack.midiGroup[index] = noteNumbers[trackId]![index]

                                        // Replace note in level
                                        for (i, n) in currentTrack.notesToLevel.enumerated() {
                                            if n == oldNote {
                                                currentTrack.notesToLevel[i] = noteNumbers[trackId]![index]
                                            }
                                        }
                                        // Replace note in grid
                                        for (i, n) in currentTrack.notesToGrid.enumerated() {
                                            if n == oldNote {
                                                currentTrack.notesToGrid[i] = noteNumbers[trackId]![index]
                                            }
                                        }
                                        // Tell parent View
                                        for (i, n) in noteNumberLetters[trackId]!.enumerated() {
                                            if n == oldNote {
                                                noteNumberLetters[trackId]![i] = noteNumbers[trackId]![index]
                                            }
                                        }
                                    }
                                }
                                .font(.system(size: 45))
                                .disabled(noteNumbers[trackId]![index] == 127)
                                .padding(.trailing)
                            }

                            let letter: String = AppUtils.midiNoteName(for: self.noteNumbers[trackId]![index])
                            Text("\(letter)").foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}
