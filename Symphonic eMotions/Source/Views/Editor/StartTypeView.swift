//
//  StartTypeView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2023.
//

import SwiftUI

struct StartTypeView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String

    let columnWidth: CGFloat = 150
    
    @State var startTypeLocal: StartType
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _startTypeLocal = State(initialValue: currentTrack.startType)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack(){
                
                Text("Start type")
                    .frame(width: columnWidth, alignment: .leading)
                
                Picker("Select starting type", selection: $startTypeLocal) {
                    ForEach(StartType.allCases, id: \.self) { type in
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: startTypeLocal) { type in
                    withAnimation {
                        
                        //Store to file
                        currentTrack.startType = type
                        //Keep local state
                        startTypeLocal = type
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
