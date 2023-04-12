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

    @Binding var trackTypeParent: [String: TrackType]
    @State var localTrackType: TrackType

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        trackTypeParent: Binding<[String: TrackType]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _trackTypeParent = trackTypeParent
        _localTrackType = State(initialValue: currentTrack.trackType)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){

            Divider()
            //Track is presenr in level
            HStack() {

                Text("MIDI clip Control")
                    .frame(width: columnWidth, alignment: .leading)
                
                let availableTypes: [TrackType] = [.midiClipLevel,.midiClipPosition]
                
                Picker("Select track type", selection: $localTrackType) {
                    ForEach(availableTypes, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: localTrackType) { trackType in
                    withAnimation {
                        //Store to file
                        currentTrack.trackType = trackType
                        //Tell parent
                        trackTypeParent[trackId] = trackType
                        //Keep local state
                        localTrackType = trackType
                    }
                }
                
//                Text(localTrackType)
                
//                Picker("Select track type", selection: $localTrackType {
//                    ForEach(availableTypes, id: \.self) { type in
//                        Text(type.rawValue).tag(type)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .onChange(of: $trackTypeParent[trackId]) { trackType in
//                    withAnimation {
//                        currentTrack.trackType = trackType!
//                        $trackTypeParent[trackId] = trackType
//                    }
//                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
