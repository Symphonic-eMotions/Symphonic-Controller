//
//  LevelView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 09/06/2022.
//

import SwiftUI

import SwiftUI

struct ProgressBarButton: View {
    
    @Binding var value: Float
    var level: Int
    var action: (Int) -> Void
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.secondary)
                
                Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.accentColor)
            }.cornerRadius(30.0)
            .onTapGesture {
                self.action(level)
            }
        }
    }
}

struct LevelView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        //Horizontal level
        HStack {
            
            //Progress bars
            HStack {
                ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.levels.count, id: \.self) { index in
                    
                    //Index is the number of the current available level
                    ProgressBarButton(
                        value: .init(
                            get: {
                                let currentBarLevel = Float(max(0, setInfoModel.leveling.currentSetLevelSubject.value - Double(index)))
                                return max(0, min(1, currentBarLevel))
                            },
                            set: { _ in }),
                        level: index,
                        action: { selectedLevel in
                            setInfoModel.leveling.currentSetLevelSubject.value = Double(selectedLevel)
                        }
                    ).frame(height: 30.0)
                }
            }
        }
    }
}
