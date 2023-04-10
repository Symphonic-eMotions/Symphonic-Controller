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
    @Binding var showEditorPart: String

    var body: some View {

        VStack(alignment: .leading) {

            ForEach(setInfoModel.setSettings.tracks.keys, id: \.self) { key in
                //Track navigation header
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

                    Text("Track \(setInfoModel.setSettings.tracks[key]!.trackName)")
                        .font(.system(size: 20))
                        .padding()
                }
                .onTapGesture {
                    withAnimation {
                        if showEditorPart != key {
                            showEditorPart = key
                        }
                    }
                }
                //If navigation header is tapped
                if showEditorPart == key {

                    InLevelView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key
                    )

                    TrackTypeView(
                        setInfoModel: setInfoModel,
                        currentTrack: setInfoModel.setSettings.tracks[key]!,
                        trackId: key
                    )

                    Text("Start Type [transport, triggerSequencer, triggerTimeLess]")
                        .padding()
                        .foregroundColor(.gray)

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
