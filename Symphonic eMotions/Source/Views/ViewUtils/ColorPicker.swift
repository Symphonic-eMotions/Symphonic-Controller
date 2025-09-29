//
//  ColorPicker.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 25/10/2022.
//

import Foundation
import OrderedCollections
import SwiftUI

struct InsrtumentColorPicker: View {
    @ObservedObject var setInfoModel: SetInfoModel
    var color: InstrumentColors = .init()
    // No color
    let testColor = Color("InstrumentNoColor")

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(color.palet, id: \.self) { color in
                    let trackId = setInfoModel.partFeedback.currentTrackID.value
                    let trackColor = setInfoModel.setSettings.tracks[trackId]?.instrumentColor
                    let parts = setInfoModel.setSettings.tracks[trackId]?.parts.values ?? OrderedDictionary<String, PartSettings>().values

                    ZStack {
                        Circle()
                            .foregroundColor(color)
                            .frame(width: 45, height: 45)
                            .opacity(color == trackColor ? 0.5 : 1.0)
                            .scaleEffect(color == trackColor ? 1.1 : 1.0)
                            .onTapGesture {
                                setInfoModel.setSettings.tracks[trackId]?.instrumentColor = color
                                setInfoModel.setSettings.tracks[trackId]?.changeAreaOfInterestColor(newColor: color)
                                setInfoModel.setInfoState.updateEditView += 1
                                if color == testColor {
                                    for part in parts {
                                        part.dontDrawVisual = true
                                    }
                                } else {
                                    for part in parts {
                                        part.dontDrawVisual = false
                                    }
                                }
                            }

                        if color == testColor {
                            Line()
                                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                                .foregroundColor(.red)
                                .rotationEffect(Angle(degrees: 45))
                                .frame(width: 50, height: 2)
                        }
                    }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}
