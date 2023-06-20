//
//  MinimalLevelView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/06/2023.
//

import SwiftUI

struct MinimalLevelView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    @State private var minimalLocal: [Double]
    
    let columnWidth: CGFloat = 150
    
    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId: String
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _minimalLocal = State(initialValue: currentTrack.parts.map { $0.value.minimalLevel })
    }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(){
                Text("Minimal level:")
                    .frame(width: columnWidth, alignment: .leading)
                
                ForEach(Array(currentTrack.parts.enumerated()), id: \.offset ){ index, part in
                    HStack{
                        Text(String(format: "%.2f", minimalLocal[index]))
                            .frame(width: 40)
                        
                        Slider(
                            value: Binding(
                                get: {
                                    part.value.minimalLevel
                                },
                                set: { newValue in
                                    part.value.minimalLevel = newValue
                                    minimalLocal[index] =  newValue
                                }
                            ),
                            in: 0...1
                        )
                    }
                    .frame(width:150)
                }
            }
        }
        .padding(.leading)
    }
}
