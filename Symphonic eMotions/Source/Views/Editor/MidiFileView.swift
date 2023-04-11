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
    
    let columnWidth: CGFloat = 150
    
    var body: some View {
        
        Divider()
        
        HStack{
        
            Text("MIDI file")
            .frame(width: columnWidth, alignment: .leading)
        
            Image(systemName: "doc")
            
            Text("\(currentTrack.midiFile).mid")
            
        }
        .padding(.leading)
        .padding(.trailing)
        
        
    }
}
