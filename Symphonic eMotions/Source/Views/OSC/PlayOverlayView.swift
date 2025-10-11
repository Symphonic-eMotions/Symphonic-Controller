//
//  PlayOverlayView.swift
//  eMotion
//
//  Created by Frans-Jan Wind on 11/10/2025.
//
import SwiftUI

struct PlayOverlayView: View {
    @ObservedObject var setInfoModel: SetInfoModel

    var body: some View {
        ZStack {
            // 1) Camerabeeld
            VideoPreviewViewRepresentable(setInfoModel: setInfoModel)
                .aspectRatio(1.77777, contentMode: .fit)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary))
                .cornerRadius(10)
                .opacity(setInfoModel.setInfoState.displayMode == .both ? 0.30 : 1.0)

            // 2) Heatmap uit AreaValues
            HeatmapGrid(
                rows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                columns: setInfoModel.setInfoState.currentInstrumentsSet.columns,
                values: setInfoModel.setInfoState.values,
                baseOpacity: 0.75 // hoe sterk de heatmap doorschemert
            )
            .allowsHitTesting(false)

            // 3) AOI per part (over kleurenlaag)
            AOIOverlay(
                rows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                columns: setInfoModel.setInfoState.currentInstrumentsSet.columns,
                tracks: setInfoModel.tracksValue
            )
            .allowsHitTesting(false)
        }
        .padding()
    }
}
