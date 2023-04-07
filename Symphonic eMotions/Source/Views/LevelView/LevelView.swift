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
                    .foregroundColor(.accentColor)
            }.cornerRadius(30.0)
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
                    ForEach(0..<playViewModel.playViewState.currentInstrumentsSet.levels.count, id: \.self) { index in
                        
                        //Index is the number of the current available level
                        
                        ProgressBar(value: .init(
                            get: {
                                let currentBarLevel = Float(max(0, playViewModel.leveling.currentSetLevelSubject.value - Double(index)))
                                return max(0, min(1, currentBarLevel))
                            },
                            set: { _ in })
                        ).frame(height: 13.0)
                    }
                }
                
                //Level buttons
                Picker(
                    "Level",
                    selection: Binding(get: {
                        Int(playViewModel.leveling.currentSetLevelSubject.value)
                    }, set: { value in
                        playViewModel.leveling.currentSetLevelSubject.value = Double(value)
                    }),
                    content: {
                        ForEach(0..<playViewModel.playViewState.currentInstrumentsSet.levels.count, id: \.self) { index in
                            Text("Level "+String(describing: (index+1))).tag(index)
                        }
                    }
                )
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(.red)
                .accentColor(.blue)
            }
            
            //Pauze level progress
            Button {
                playViewModel.leveling.pauseLevel.toggle()
            } label: {
                
                Image(systemName: "pause")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .frame(width: 30, height: 30 )
                    .padding(.top)
                    .opacity(playViewModel.leveling.pauzeOpacity(isPlaying: playViewModel.conductor.isConductorPlayingSubject.value))
                    .padding(.bottom)
            }
        }
    }
}
