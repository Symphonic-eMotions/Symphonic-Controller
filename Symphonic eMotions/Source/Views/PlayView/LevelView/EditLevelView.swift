//
//  EditLevelView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 31/10/2022.
//

import SwiftUI

struct EditLevelView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @ObservedObject var currentTrackLevels: TrackLevelsModel
    
    init(
        playViewModel: PlayViewModel,
        currentTrackLevels: TrackLevelsModel
    ){
        self.playViewModel = playViewModel
        self.currentTrackLevels = currentTrackLevels
    }
    
    var body: some View {
        
        HStack {
            
            ForEach(0..<playViewModel.playViewState.currentInstrumentsSet.levelDurations.count, id: \.self) { index in
                                
                let inLevel: Bool = self.currentTrackLevels.levels.contains(index) ? true : false
                
                EMButtonLevels(
                    playViewModel: playViewModel,
                    levelIndex: index,
                    inLevel: inLevel
                )
            }
        }
        .frame(height: 50)
        .padding(.top)

    }
}

struct EMButtonLevels: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    let color: Color = .accentColor
    var levelIndex: Int
    var inLevel: Bool
    
    var body: some View {
        
        Button(action: {
            playViewModel.setSettings.updateLevelIndex(trackId: playViewModel.partFeedback.currentTrackID.value, level: levelIndex)
            playViewModel.playViewState.updateEditView += 1
        }) {
            ZStack{
                Text("Level \(levelIndex+1)")
            }
        }
        .padding(.horizontal)
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .font(.system(size: 17).weight(.semibold))
        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(color))
        .foregroundColor(inLevel ? .white : color)
        .background(inLevel ? color : .clear)
        .cornerRadius(6.0)
    }
}
