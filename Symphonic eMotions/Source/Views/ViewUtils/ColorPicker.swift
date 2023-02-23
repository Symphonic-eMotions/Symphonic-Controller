//
//  ColorPicker.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 25/10/2022.
//

import Foundation
import SwiftUI

struct InsrtumentColorPicker: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    var color: InstrumentColors = InstrumentColors()
    
    var body: some View {
        
        ScrollView(.horizontal) {
            HStack{
                ForEach(color.palet, id:\.self) { color in
                    
                    let trackId = playViewModel.partFeedback.currentTrackID.value
                    let trackColor = playViewModel.setSettings.tracks[trackId]?.instrumentColor
                    
                    Circle()
                        .foregroundColor(color)
                        .frame(width: 45, height: 45)
                        .opacity(color == trackColor ? 0.5 : 1.0)
                        .scaleEffect(color == trackColor ? 1.1 : 1.0)
                        .onTapGesture {
                            playViewModel.setSettings.tracks[trackId]?.instrumentColor = color
                            playViewModel.setSettings.tracks[trackId]?.changeAreaOfInterestColor(newColor: color)
                            playViewModel.playViewState.updateEditView += 1
                        }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}
