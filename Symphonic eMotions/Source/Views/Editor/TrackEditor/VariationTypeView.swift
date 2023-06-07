//
//  VariationTypeView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 10/04/2023.
//

import SwiftUI

struct VariationTypeView: View{
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    var trackId: String

    let columnWidth: CGFloat = 150
//    let color: Color = .accentColor

    @Binding var variationTypeParent: [String: VariationType]
    @State var localVariationType: VariationType

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        variationTypeParent: Binding<[String: VariationType]>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _variationTypeParent = variationTypeParent
        _localVariationType = State(initialValue: currentTrack.variationType)
    }
    
    var body: some View {
        
        VStack(alignment: .leading){

            Divider()
            //Track is presenr in level
            HStack() {

                Text("Variation")
                    .frame(width: columnWidth, alignment: .leading)
                
                let availableTypes: [VariationType] = [.variationByLevel,.variationByPosition,.variationSequencial]
                
                //Level, Position, sequencial
                Picker("Select track type", selection: $localVariationType) {
                    ForEach(availableTypes, id: \.self) { type in
                        
                        Text(type.description).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: localVariationType) { type in
                    withAnimation {
                        //Store to file
                        currentTrack.variationType = type
                        //Tell parent
                        variationTypeParent[trackId] = type
                        //Keep local state
                        localVariationType = type
                    }
                }
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}
