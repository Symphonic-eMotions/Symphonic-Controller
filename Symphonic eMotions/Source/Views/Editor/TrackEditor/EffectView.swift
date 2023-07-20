//
//  EffectView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 19/07/2023.
//

import SwiftUI

struct EffectView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    //This is a 1 track View
    @State var trackId: String
    @Binding var showTrackEffect: Bool
    
    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showTrackEffect: Binding<Bool>
    ) {
        self.setInfoModel = setInfoModel
        self.currentTrack = currentTrack
        self.trackId = trackId
        _showTrackEffect = showTrackEffect
    }
    
    let columnWidth: CGFloat = 150
    let color: Color = .accentColor
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Divider()
            
            HStack() {
                
                VStack {
                    
                    ZStack {
                        
                        Rectangle()
                            .frame(width: 130, height: 34)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background( showTrackEffect ? .clear : color )
                        
                        Text("Effects")
                            .frame(width: 130, height: 34)
                        
                    }
                    .frame(width: columnWidth, alignment: .leading)
                    .onTapGesture {
                        withAnimation {
                            showTrackEffect.toggle()
                        }
                    }
                    
                }
                HStack(spacing: 20) {
                    
                    Text("Edit effect butttons")
                    
//                    ForEach(Array(currentTrack.effects.values), id: \.id) { effect in
//                        Text(effect.name)
//                    }
                    
                }
                .sheet(isPresented: $showTrackEffect) {
                    
                    TrackEffectView(
                        setInfoModel: setInfoModel,
                        currentTrack: currentTrack,
                        trackId: trackId,
                        showTrackEffect: $showTrackEffect
                    )
                }
            }
        }
        .padding(.leading)
    }
}
