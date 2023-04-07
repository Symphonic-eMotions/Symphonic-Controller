//
//  EditTracks.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/04/2023.
//

import SwiftUI

struct Item: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let details: String
}

struct EditTracks: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    @State private var selectedItem: String? = nil
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            ForEach(setInfoModel.setSettings.tracks.keys, id: \.self) { key in
                
                HStack{
                    
                    Group{
                        Image("track")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .padding(4)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                    }
                    .padding(.leading)
                    
                    Text(setInfoModel.setSettings.tracks[key]!.trackName)
                        .font(.system(size: 20))
                        .padding()
                }
                .onTapGesture {
                    withAnimation {
                        if selectedItem == key {
                            selectedItem = nil
                        } else {
                            selectedItem = key
                        }
                    }
                }
                
                if selectedItem == key {
//                    LoopsToGridView(setInfoModel: setInfoModel, key: key)
                    LoopsToLevelView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key
                    )
                }
            }
        }
    }
}
