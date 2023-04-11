//
//  TrackTypeView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 10/04/2023.
//

import SwiftUI

struct TrackTypeView: View{
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String

    let columnWidth: CGFloat = 150
    let color: Color = .accentColor

    @Binding var trackTypeParent: TrackType

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        trackTypeParent: Binding<TrackType>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _trackTypeParent = trackTypeParent
    }
    
    var body: some View {
        
        VStack(alignment: .leading){

            Divider()
            //Track is presenr in level
            HStack() {

                Text("MIDI clip Control")
                    .frame(width: columnWidth, alignment: .leading)
                
                let availableTypes: [TrackType] = [.midiClipLevel,.midiClipPosition]
                
                Picker("Select track type", selection: $trackTypeParent) {
                    ForEach(availableTypes, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: trackTypeParent) { trackType in
                    withAnimation {
                        currentTrack.trackType = trackType
                        trackTypeParent = trackType
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
