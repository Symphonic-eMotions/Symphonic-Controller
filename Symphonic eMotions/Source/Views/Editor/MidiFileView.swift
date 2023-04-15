//
//  MidiFileView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 11/04/2023.
//

import SwiftUI

struct MidiFileView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    @State var isPlaying: Bool = false
    @State var loopLength: Int = 16
    @State var isLooping = false
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId:String
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _loopLength = State(initialValue: Int(currentTrack.loopLength.first ?? 16))
    }
    
    var body: some View {
        
        HStack{
        
            Text("MIDI file")
            .frame(width: columnWidth, alignment: .leading)
            
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            .foregroundColor(.white)
//            .font(.system(size: 25))
            .frame(width: 40, height: 30)
            .padding(.vertical, 5.0)
            .padding(.horizontal, 5.0)
            .background(Color.accentColor)
            .cornerRadius(5.0)
            .onTapGesture {
                isPlaying.toggle()
                setInfoModel.conductor.previewSingleTrack(trackId: trackId)
            }
            
//            TextField("Looplength", text: Binding(
//                get: {String(self.loopLength)},
//                set: {
//                    if let value = Int($0) {
//                        self.loopLength = value
//                        isLooping = false
//                    }
//                }
//            ))
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .frame(width: 50)
//            .padding(.leading)
//            .padding(.trailing)
//            
//            Image(systemName: "arrow.counterclockwise")
//            .foregroundColor(.white)
////            .font(.system(size: 25))
//            .frame(width: 40, height: 30)
//            .padding(.vertical, 5.0)
//            .padding(.horizontal, 5.0)
//            .background( isLooping ? Color.accentColor : .clear)
//            .cornerRadius(5.0)
//            .onTapGesture {
//                setInfoModel.conductor.loopSingleTrack(
//                    trackId: trackId,
//                    loopLength: Double(loopLength),
//                    isLooping: isLooping
//                )
//                isLooping.toggle()
//            }
            
            Text("\(currentTrack.midiFile).mid")
            
            
            
        }
    }
}
