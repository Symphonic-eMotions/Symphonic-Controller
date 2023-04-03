//
//  EditTracks.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/04/2023.
//

import SwiftUI

struct EditTracks: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        
        ForEach(setInfoModel.setSettings.tracks.keys, id: \.self) { key in
            
            HStack{
                
                Group{
                    Image("track")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                }.padding(.leading)
                
                Text(setInfoModel.setSettings.tracks[key]!.trackName)
                    .font(.system(size: 20))
                    .padding()
            }
            
//            let p: String = setInfoModel.setSettings.tracks[key]?.loopsToGrid.map({ String($0) }).joined(separator: ", ")
            
//            Text("Midi File mapping used: ")
            
            
        }
    }
}
