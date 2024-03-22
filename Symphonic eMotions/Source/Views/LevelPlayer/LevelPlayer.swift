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
    @Binding var showLevelPlayerFullScreen: Bool
    var geometry: GeometryProxy
    
    var body: some View {
        ZStack(alignment: .center) {
            ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.levels.count, id: \.self) { index in
                SVGImageViewContainer(
                    levelPlayerModel: levelPlayerModel,
                    setInfoModel: setInfoModel,
                    geometry: geometry,
                    level: index,
                    imageName: "level\(index)",
                    scale: .init(
                        get: {
                            let currentBarLevel = Float(max(0, setInfoModel.leveling.currentSetLevelSubject.value - Double(index)))
                            return max(0, min(1, currentBarLevel))
                        },
                        set: { _ in }
                    )
                )
                .frame(
                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
                )
            }
            
            // Voeg de fullscreen toggle knop toe
            Button(action: {
                withAnimation(.easeInOut) {
                    self.showLevelPlayerFullScreen.toggle()
                }
            }) {
                Image(systemName: showLevelPlayerFullScreen 
                      ? "arrow.down.right.and.arrow.up.left"
                      : "arrow.up.left.and.arrow.down.right"
                )
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .padding() // Zorgt voor wat ruimte rondom het icoon
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor.opacity(0.1)))
            }
            .position(
                x: showLevelPlayerFullScreen ? UIScreen.main.bounds.width - 30 : geometry.size.width - 30,
                y: showLevelPlayerFullScreen ? UIScreen.main.bounds.height - 45 : geometry.size.height - 45
            )
            .zIndex(300) // Zorgt ervoor dat de knop bovenop ligt
            
        }
        .frame(
            width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
            height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
        )
        .background(showLevelPlayerFullScreen ? Color.black : Color.clear)
        .edgesIgnoringSafeArea(showLevelPlayerFullScreen ? .all : .init())
        .zIndex(showLevelPlayerFullScreen ? 201 : 0) // Verhoog de zIndex wanneer fullscreen
    }
}
