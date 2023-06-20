////
////  LoopsToLevelView.swift
////  Symphonic eMotions Pro
////
////  Created by Frans-Jan Wind on 05/04/2023.
////

import SwiftUI

struct MidiClipName: View {

    var value: String

    var body: some View {
        ZStack {

            Rectangle()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
            Text("\(value)")
                .foregroundColor(.primary)
        }
    }
}

struct MidiClipLevelView: View {

    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    //Binding
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
        midiClips: Binding<[String:[Double]]>,
        midiClipLetters: Binding<[String:[Int]]>,
        midiClipsLevels: Binding<[String: [Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _trackLevels = trackLevels
        _midiClips = midiClips
        _midiClipLetters = midiClipLetters
        _midiClipsLevels = midiClipsLevels
    }

    var body: some View {

        VStack(alignment: .leading){

            Divider()

            //Place clips in level
            HStack(){

                Text("Place clip in level:")
                .frame(width: columnWidth, alignment: .leading)

                ForEach(0..<trackLevels[trackId]!.count, id: \.self) { index in

                    VStack{

                        ZStack {

                            let levelClip = midiClipsLevels[trackId]![index]
                            let clipLetter: String = AppUtils.letterForNumber(levelClip) ?? "-"
                            
                            Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            
                            Text("\(clipLetter)")
                            .foregroundColor(.white)
                        }
                        .onTapGesture {
                            
                            let increment = midiClipsLevels[trackId]![index] + 1
                            let incrementModulo = increment % midiClipLetters[trackId]!.count
                            
                            print("clipLetters \(midiClipLetters[trackId]!.map(String.init).joined(separator: ", ")) index \(index) updated with \(increment) % \(midiClipLetters[trackId]!.count) = \(incrementModulo)")
                            
                            currentTrack.loopsToLevel[index] = incrementModulo
                            midiClipsLevels[trackId]![index] = incrementModulo
                        }
                    }
                }
            }
        }
        .padding(.leading)
//        .onAppear {
//            // Set initial value of syncedValue to value from observed object
//            loopLengthLocal = setInfoModel.setSettings.tracks[trackId]!.loopLength
//        }
//        .onChange(of: updateView) { _ in
//            loopsToLevelLocal = currentTrack.loopsToLevel
//        }
    }

}
