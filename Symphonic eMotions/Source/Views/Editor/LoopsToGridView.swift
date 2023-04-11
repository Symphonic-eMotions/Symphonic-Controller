//
//  LoopsToGridView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 04/04/2023.
//

import SwiftUI

struct LoopsToGridView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    @State var loopLengthLocal: [Double]
    @State private var clipLetters: [Int]
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String ){
            self.setInfoModel = setInfoModel
            self.currentTrack = currentTrack
            self.trackId = trackId
            _loopLengthLocal = State(initialValue: currentTrack.loopLength)
//            _clipLength = State(initialValue: Int(currentTrack.loopLength.first ?? 16))
//            _levels = State(initialValue: setInfoModel.setSettings.levels)
            _clipLetters = State(initialValue: currentTrack.loopsToGrid)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            MidiClipsInFile(
                setInfoModel: setInfoModel,
                currentTrack: currentTrack,
                trackId: trackId,
                loopLengthLocal: $loopLengthLocal,
                clipLetters: $clipLetters
            )
            
            HStack(){
                
                Text("Place clip in level: ")
                .frame(width: columnWidth, alignment: .leading)
        
                let gridRows: Int = setInfoModel.setSettings.gridRows
                let gridColumns: Int = setInfoModel.setSettings.gridColumns
                                
                VStack(spacing: 0) {
                    ForEach(0..<gridRows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<gridColumns, id: \.self) { column in
                                
                                ZStack {
                                    
                                    Rectangle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.clear)
                                    .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                    
                                    
//
                                    Text("\(row) x \(column)")
                                    .foregroundColor(.blue)
                                    
//                                    index = index + 1
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
