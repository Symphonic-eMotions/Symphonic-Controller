////
////  LoopsToLevelView.swift
////  Symphonic eMotions Pro
////
////  Created by Frans-Jan Wind on 05/04/2023.
////

import SwiftUI

struct MidiClipLevelView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    // This is a 1 track View
    @State var trackId: String

    // Binding
    @Binding var trackLevels: [String: [Int]]
    @Binding var midiClips: [String: [Double]]
    @Binding var midiClipLetters: [String: [Int]]
    @Binding var midiClipsLevels: [String: [Int]]

    let columnWidth: CGFloat = 150

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        trackLevels: Binding<[String: [Int]]>,
        midiClips: Binding<[String: [Double]]>,
        midiClipLetters: Binding<[String: [Int]]>,
        midiClipsLevels: Binding<[String: [Int]]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _trackLevels = trackLevels
        _midiClips = midiClips
        _midiClipLetters = midiClipLetters
        _midiClipsLevels = midiClipsLevels
    }

    var body: some View {
        VStack(alignment: .leading) {
            Divider()

            // Place clips in level
            HStack {
                Text("Place clip in level:")
                    .frame(width: columnWidth, alignment: .leading)

                ForEach(0 ..< setInfoModel.setSettings.levels.count, id: \.self) { level in
                    VStack {
                        let levelNumber = level + 1
                        Text("\(levelNumber)")
                            .foregroundColor(.blue)

                        ZStack {
                            let levelClip = midiClipsLevels[trackId]![level]
                            let clipLetter: String = AppUtils.letterForNumber(levelClip) ?? "-"

                            Rectangle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))

                            Text("\(clipLetter)")
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            let increment = midiClipsLevels[trackId]![level] + 1
                            let incrementModulo = increment % midiClipLetters[trackId]!.count

                            print("clipLetters Mifi Files \(midiClipLetters[trackId]!.map(String.init).joined(separator: ", ")) index \(level) updated with \(increment) % \(midiClipLetters[trackId]!.count) = \(incrementModulo)")

                            currentTrack.loopsToLevel[level] = incrementModulo
                            midiClipsLevels[trackId]![level] = incrementModulo
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
