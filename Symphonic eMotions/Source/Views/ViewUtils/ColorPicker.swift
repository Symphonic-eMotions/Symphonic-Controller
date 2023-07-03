//
//  ColorPicker.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 25/10/2022.
//

import Foundation
import SwiftUI

struct InsrtumentColorPicker: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    var color: InstrumentColors = InstrumentColors()
    
    var body: some View {
        
        ScrollView(.horizontal) {
            HStack{
                ForEach(color.palet, id:\.self) { color in
                    
                    let trackId = setInfoModel.partFeedback.currentTrackID.value
                    let trackColor = setInfoModel.setSettings.tracks[trackId]?.instrumentColor
                    
                    Circle()
                        .foregroundColor(color)
                        .frame(width: 45, height: 45)
                        .opacity(color == trackColor ? 0.5 : 1.0)
                        .scaleEffect(color == trackColor ? 1.1 : 1.0)
                        .onTapGesture {
                            setInfoModel.setSettings.tracks[trackId]?.instrumentColor = color
                            setInfoModel.setSettings.tracks[trackId]?.changeAreaOfInterestColor(newColor: color)
                            setInfoModel.setInfoState.updateEditView += 1
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
