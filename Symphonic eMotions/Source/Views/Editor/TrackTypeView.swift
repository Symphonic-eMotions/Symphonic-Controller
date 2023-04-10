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

    @State private var trackType: TrackType

    init(setInfoModel: SetInfoModel, currentTrack: TrackSettings, trackId: String) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _trackType = State(initialValue: currentTrack.trackType)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){

            Divider()
            //Track is presenr in level
            HStack() {

                Text("MIDI clip Control")
                    .frame(width: columnWidth, alignment: .leading)

                Picker("Select track type", selection: $trackType) {
                    ForEach(TrackType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: trackType) { trackType in
                    currentTrack.trackType = trackType
                }
            }
        }
        .padding(.leading)
    }
}
