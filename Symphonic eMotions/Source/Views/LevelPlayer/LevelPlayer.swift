//
//  LevelPlayer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2024.
//

import SwiftUI

struct LevelPlayer: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var columnOpacityController: ColumnOpacityController
    @ObservedObject var gridModel: GridModel
    @Binding var showLevelPlayerFullScreen: Bool
    var geometry: GeometryProxy
    
    var body: some View {
        ZStack(alignment: .center) {
            
            if setInfoModel.setSettings.userViews.contains(.columnView) {
                
                ColumnView(
                    setInfoModel: setInfoModel,
                    columnOpacityController: columnOpacityController,
                    rows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                    columns: setInfoModel.setInfoState.currentInstrumentsSet.columns,
                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height - 20 : geometry.size.height
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
            }
            else if setInfoModel.setSettings.userViews.contains(.gridView){
                
//                GridView(
//                    setInfoModel: setInfoModel,
//                    opacityController: columnOpacityController,
//                    rows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
//                    columns: setInfoModel.setInfoState.currentInstrumentsSet.columns,
//                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
//                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
//                )
//                .frame(
//                    width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
//                    height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
//                )
//                .position(
//                    x: showLevelPlayerFullScreen ? UIScreen.main.bounds.width / 2 : geometry.size.width / 2,
//                    y: showLevelPlayerFullScreen ? UIScreen.main.bounds.height / 2 : geometry.size.height / 2
//                )
//                .onAppear {
//                    // Inline en fullscreen grootte bepalen en doorgeven
//                    let inlineSize = CGSize(
//                        width: geometry.size.width,
//                        height: geometry.size.height
//                    )
//                    let fullscreenSize = UIScreen.main.bounds.size
//                    gridModel.updateCellCenters(inlineSize: inlineSize, fullscreenSize: fullscreenSize)
//                    
//                    gridModel.initializeViewCenters(
//                        inlineSize: CGSize(width: geometry.size.width, height: geometry.size.height),
//                        fullscreenSize: UIScreen.main.bounds.size // Of een andere logica voor het bepalen van de fullscreen grootte
//                    )
//                }
            }
            
            if setInfoModel.setSettings.userViews.contains(.levelPlayer){
                
                //SVG Animation
                ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.levels.count, id: \.self) { index in
                    
                    SVGImageViewContainer(
                        setInfoModel: setInfoModel,
                        gridModel: gridModel,
                        showLevelPlayerFullScreen: $showLevelPlayerFullScreen, 
                        levelFromIndex: index,
                        geometry: geometry
                        
                    )
                    .frame(
                        width: showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width,
                        height: showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
                    )
                    .offset(x: gridModel.xOffset, y: gridModel.yOffset)
                }
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
    
    func calculateInitialOffsetX(for geometry: GeometryProxy, showLevelPlayerFullScreen: Bool) -> CGFloat {
        let viewCenter = showLevelPlayerFullScreen ? gridModel.fullscreenViewCenter : gridModel.inlineViewCenter
        let correctionX: CGFloat = 250
        return viewCenter.x - (geometry.size.width / 2) - correctionX
    }

    func calculateInitialOffsetY(for geometry: GeometryProxy, showLevelPlayerFullScreen: Bool) -> CGFloat {
        let viewCenter = showLevelPlayerFullScreen ? gridModel.fullscreenViewCenter : gridModel.inlineViewCenter
        let correctionY: CGFloat = 250
        return viewCenter.y - (geometry.size.height / 2) - correctionY
    }
    
//    func calculateInitialOffsetX(for geometry: GeometryProxy, showLevelPlayerFullScreen: Bool) -> CGFloat {
//        let viewCenter = showLevelPlayerFullScreen ? gridModel.fullscreenViewCenter : gridModel.inlineViewCenter
//        // Aanname: SVGImageView's breedte is gelijk aan de breedte van de container
//        let containerWidth = showLevelPlayerFullScreen ? UIScreen.main.bounds.width : geometry.size.width
//        return viewCenter.x - (containerWidth / 2)
//    }
//
//    func calculateInitialOffsetY(for geometry: GeometryProxy, showLevelPlayerFullScreen: Bool) -> CGFloat {
//        let viewCenter = showLevelPlayerFullScreen ? gridModel.fullscreenViewCenter : gridModel.inlineViewCenter
//        // Aanname: SVGImageView's hoogte is gelijk aan de hoogte van de container
//        let containerHeight = showLevelPlayerFullScreen ? UIScreen.main.bounds.height : geometry.size.height
//        return viewCenter.y - (containerHeight / 2)
//    }

}
