//
//  LevelPlayer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2024.
//

import SwiftUI

struct LevelPlayer: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var levelPlayerModel: LevelPlayerModel
    var geometry: GeometryProxy
    
    var body: some View {
        //Progress bars
        ZStack {
            ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.levels.count, id: \.self) { index in
                //Index is the number of the current available level
                SVGImageViewContainer(
                    levelPlayerModel: levelPlayerModel,
                    geometry: geometry,
                    level: index,
                    imageName: "level\(index)",
                    scale: .init(
                        get: {
                            let currentBarLevel = Float(max(0, setInfoModel.leveling.currentSetLevelSubject.value - Double(index)))
                            return max(0, min(1, currentBarLevel))
                        },
                        set: { _ in })
                )
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
            
        }
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
//        .aspectRatio(1.77777, contentMode: .fit)
    }
}
