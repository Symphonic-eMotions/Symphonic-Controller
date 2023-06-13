//
//  AreaConnection.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 07/05/2023.
//

import SwiftUI

struct AreaConnectionView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    
    //This is a 1 track View
    @State var trackId: String
    
    let columnWidth: CGFloat = 150
        
    init(
        setInfoModel:SetInfoModel,
        currentTrack:TrackSettings,
        trackId: String
    ){
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
    }
    
    
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack(){
                
                Text("Area connection")
                    .frame(width: columnWidth, alignment: .leading)
                
                HStack(spacing: 20) {
                    
                    ForEach(Array(currentTrack.parts.enumerated()), id: \.offset ){ index, part in
                        
                        VStack {
                            
                            //Name of the Part shown
                            Text(part.value.partName)
                                .padding()
                            
                            Text(part.value.damperTarget.nodeName)
                            Text(part.value.damperTarget.parameter)
                            Text(part.value.damperTarget.parameterRange.map{String($0)}.joined(separator: ","))
                        }
                    }
                }
            }
        }
        .padding(.leading)
    }
}
