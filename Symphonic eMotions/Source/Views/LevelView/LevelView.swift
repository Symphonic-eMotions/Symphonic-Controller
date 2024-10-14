//
//  LevelView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 09/06/2022.
//

import SwiftUI

struct LevelView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        //Horizontal level
        VStack {
            
            let level = setInfoModel.leveling.currentSetLevelSubject.value / Double(setInfoModel.setInfoState.currentInstrumentsSet.levels.count)
            
            Text("Level: \(level)")
                .padding()
            
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
