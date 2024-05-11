//
//  LoopsToGridView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 04/04/2023.
//

import SwiftUI

struct MidiClipsPositionsView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    
    //Binding
    @Binding var midiClips: [String: [Double]]
    @Binding var midiClipLetters: [String: [Int]]
    @Binding var midiClipsPositions: [String: [Int]]
    
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        midiClips: Binding<[String:[Double]]>,
        midiClipLetters: Binding<[String:[Int]]>,
        midiClipsPositions: Binding<[String:[Int]]>
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _midiClips = midiClips
        _midiClipLetters = midiClipLetters
        _midiClipsPositions = midiClipsPositions
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
                    
            HStack(){
                        
                Text("Place clip in grid: ")
                .frame(width: columnWidth, alignment: .leading)
                
                let gridRows: Int = setInfoModel.setSettings.gridRows
                let gridColumns: Int = setInfoModel.setSettings.gridColumns

                VStack(spacing: 0) {
                            
                    let cellWidth: CGFloat = gridColumns > 0 ? CGFloat(200 / gridColumns - 1) : 0
                    ForEach(0..<gridRows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<gridColumns, id: \.self) { column in

                                let cellIndex =  row * gridColumns + column

                                if let positions = midiClipsPositions[trackId], positions.count > cellIndex {
                                    ZStack {

                                        Rectangle()
                                        .frame(width: cellWidth, height: cellWidth)
                                        .foregroundColor(.blue)
                                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))

                                        let clipPosition = positions[cellIndex]
                                        let clipLetter: String = AppUtils.letterForNumber(clipPosition) ?? "-"

                                        Text("\(clipLetter)")
                                        .foregroundColor(.white)
                                    }
                                    .onTapGesture {
                                        if let letters = midiClipLetters[trackId], letters.count > 0 {
                                            let increment = positions[cellIndex] + 1
                                            let incrementModulo = increment % letters.count

                                            currentTrack.loopsToGrid[cellIndex] = incrementModulo
                                            midiClipsPositions[trackId]![cellIndex] = incrementModulo
                                        }
                                    }
                                }
                            }
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
//            loopsToGridLocal = currentTrack.loopsToGrid
//        }
    }
}
