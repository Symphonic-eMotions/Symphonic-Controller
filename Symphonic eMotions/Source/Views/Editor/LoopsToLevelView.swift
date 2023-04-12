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

struct LoopsToLevelView: View {

    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String
    @State var loopLengthLocal: [Double]
    @State private var levels: [Int]
    @Binding var clipLetters: [String:[Int]]

    let columnWidth: CGFloat = 150

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        clipLetters: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _loopLengthLocal = State(initialValue: currentTrack.loopLength)
        _levels = State(initialValue: setInfoModel.setSettings.levels)
        _clipLetters = clipLetters
    }

    var body: some View {

        VStack(alignment: .leading){

            Divider()
            //MIDI clips in file AND MIDi clip lengths
            //This is located here for _loopLengthLocal relation instead of higher up
            MidiClipsInFile(
                setInfoModel: setInfoModel,
                currentTrack: currentTrack,
                trackId: trackId,
                loopLengthLocal: $loopLengthLocal,
                clipLetters: $clipLetters
            )

            //Place clips in level
            HStack(){

                Text("Place clip in level: ")
                .frame(width: columnWidth, alignment: .leading)

                ForEach(0..<levels.count, id: \.self) { index in

                    VStack{

                        ZStack {

                            Rectangle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))

                            let levelClip = currentTrack.loopsToLevel[index]
                            let clipLetter: String = AppUtils.letterForNumber(levelClip) ?? "-"

                            Text("\(clipLetter)")
                            .foregroundColor(.blue)
                        }
                        .onTapGesture {
                            
                            let increment = currentTrack.loopsToLevel[index] + 1
                            
                            print("INCREMENT: \(increment)")
                            
                            let incrementModulo = increment % (clipLetters[trackId]!.count - 1)

                            currentTrack.loopsToLevel[index] = incrementModulo
                        }
                    }
                }
            }
        }
        .padding(.leading)
        .onAppear {
            // Set initial value of syncedValue to value from observed object
            loopLengthLocal = setInfoModel.setSettings.tracks[trackId]!.loopLength
        }
        .onChange(of: setInfoModel.setSettings.tracks[trackId]!.loopLength) { newValue in
            // Update syncedValue when value in observed object changes
            loopLengthLocal = newValue
        }
//        .onChange(of: loopLengthLocal) { newValue in
//            // Update value in observed object when syncedValue changes
//            loopLengthLocal.value = newValue
//        }
    }

}
