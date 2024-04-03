//
//  LevelPlayer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2024.
//

import SwiftUI

struct LevelPlayer: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var opacityController: CellOpacityController
    @ObservedObject var gridModel: GridModel
    @Binding var showLevelPlayerFullScreen: Bool
    var geometry: GeometryProxy
    
    var body: some View {
        ZStack(alignment: .center) {
            GridView(
                setInfoModel: setInfoModel,
                opacityController: opacityController,
                rows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                columns: setInfoModel.setInfoState.currentInstrumentsSet.columns,
                width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
            )
            .frame(
                width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
            )
            .position(
                x: showLevelPlayerFullScreen ? UIScreen.main.bounds.width / 2 : geometry.size.width / 2,
                y: showLevelPlayerFullScreen ? UIScreen.main.bounds.height / 2 : geometry.size.height / 2
            )
            .onAppear {
                // Inline en fullscreen grootte bepalen en doorgeven
                let inlineSize = CGSize(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                let fullscreenSize = UIScreen.main.bounds.size
                gridModel.updateCellCenters(inlineSize: inlineSize, fullscreenSize: fullscreenSize)
                
                gridModel.initializeViewCenters(
                    inlineSize: CGSize(width: geometry.size.width, height: geometry.size.height),
                    fullscreenSize: UIScreen.main.bounds.size // Of een andere logica voor het bepalen van de fullscreen grootte
                )
            }
            
            //SVG Animation
            ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.levels.count, id: \.self) { index in
                
                SVGImageViewContainer(
                    setInfoModel: setInfoModel,
                    gridModel: gridModel,
                    showLevelPlayerFullScreen: $showLevelPlayerFullScreen, 
                    levelFromIndex: index,
                    geometry: geometry
                    
                )
                .onChange(of: setInfoModel.setSettings.maxIndex) { maxIndex in
                    //TODO: kan duration variabel met level input?
                    withAnimation(.easeInOut(duration: 1.0)) {
                        gridModel.calculateAnimation(
                            for: index,
                            at: maxIndex,
                            showLevelPlayerFullScreen
                        )
                    }
                }
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
