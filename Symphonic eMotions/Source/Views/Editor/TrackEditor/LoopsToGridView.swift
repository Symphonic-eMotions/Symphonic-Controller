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
    @Binding var clipLetters: [String:[Int]]
    @State var loopsToGridLocal: [Int]
    
    @State private var updateView: Int = 0
    
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
        _clipLetters = clipLetters
        _loopsToGridLocal = State(initialValue: currentTrack.loopsToGrid)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            MidiClipsInFileView(
                setInfoModel: setInfoModel,
                currentTrack: currentTrack,
                trackId: trackId,
                loopLengthLocal: $loopLengthLocal,
                clipLetters: $clipLetters,
                updateView: $updateView
            )
            
            HStack(){
                
                Text("Place clip in grid: ")
                .frame(width: columnWidth, alignment: .leading)
        
                let gridRows: Int = setInfoModel.setSettings.gridRows
                let gridColumns: Int = setInfoModel.setSettings.gridColumns
                                
                VStack(spacing: 0) {
                    ForEach(0..<gridRows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<gridColumns, id: \.self) { column in
                                
                                let cellIndex =  row * gridColumns + column
                                
                                ZStack {
                                    
                                    Rectangle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.clear)
                                    .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                    
                                    let levelClip = loopsToGridLocal[cellIndex]
                                    let clipLetter: String = AppUtils.letterForNumber(levelClip) ?? "-"
                                    
                                    Text("\(clipLetter)")
                                    .foregroundColor(.blue)
                                }
                                .onTapGesture {
                                    
                                    let increment = loopsToGridLocal[cellIndex] + 1
                                    let incrementModulo = increment % clipLetters[trackId]!.count
                                    
                                    currentTrack.loopsToGrid[cellIndex] = incrementModulo
                                    loopsToGridLocal[cellIndex] = incrementModulo
                                }
                            }
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
        .onChange(of: updateView) { _ in
            loopsToGridLocal = currentTrack.loopsToGrid
        }
    }
}
