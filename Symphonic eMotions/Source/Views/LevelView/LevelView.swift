//
//  LevelView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 09/06/2022.
//

import SwiftUI

struct ProgressBar: View {
    
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.secondary)
                
                Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.primary)
            }.cornerRadius(45.0)
        }
    }
}

struct LevelView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    
    var body: some View {
        //Horizontal level
        HStack {
            //Vertical Progress bars and Level buttons
            VStack {
                //Progress bars
                HStack {
                    ForEach(0..<playViewModel.playViewState.currentInstrumentsSet.levelDurations.count, id: \.self) { index in
                        
                        ProgressBar(value: .init(get: {
                            let currentBarLevel = Float(max(0, playViewModel.leveling.currentSetLevelSubject.value - Double(index)))
                            return max(0, min(1, currentBarLevel))
                        }, set: { _ in })).frame(height: 20.0)
                        
                    }
                }.padding(.top)
                
                //Level buttons
                
                Picker(
                    "Level",
                    selection: Binding(get: {
                        Int(playViewModel.leveling.currentSetLevelSubject.value)
                    }, set: { value in
                        playViewModel.leveling.currentSetLevelSubject.value = Double(value)
                    }),
                    content: {
                        ForEach(0..<playViewModel.playViewState.currentInstrumentsSet.levelDurations.count, id: \.self) { index in
                            Text("Level "+String(describing: (index+1))).tag(index)
                        }
                    }
                )
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(.red)
                .accentColor(.blue)
//                .padding(.leading, 55)
            }
            
            //Pauze level progress
            if playViewModel.conductor.isConductorPlayingSubject.value {
                Button {
                    playViewModel.leveling.pauseLevel.toggle()
                } label: {
                    Image(systemName: playViewModel.leveling.pauseLevel ? "play" : "pause")
                        .font(.system(size: 50, weight: .medium, design: .rounded))
                        .frame(width: 70, height: 70 )
                        .padding(.top)
                        .zIndex(210)
                }
            }
            else{
                Image("Logo")
                    .font(.system(size: 40, weight: .medium, design: .rounded))
                    .frame(width: 50, height: 50 )
                    .foregroundColor(.gray)
                    .padding(.top)
            }
        }
    }
}
