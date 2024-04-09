//
//  GridView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/03/2024.
//

import SwiftUI

struct GridView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var opacityController: CellOpacityController
    
    let rows: Int
    let columns: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        
        let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: self.columns)
        let totalVerticalSpacing = CGFloat(self.rows - 1) * 20
        let cellHeight = (height - totalVerticalSpacing - 40) / CGFloat(self.rows)
        
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0..<self.rows * self.columns, id: \.self) { index in
                let color: Color = [.red, .blue, .green, .yellow][index % 4]
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 2)
                    .background(color.opacity(0.2))
                    .frame(width: width / CGFloat(self.columns) - 30, height: cellHeight)
                    .opacity(opacityController.opacities[index]) // Gebruik 'opacities' in plaats van 'columnOpacities'
            }
        }
        .padding(20)
        .onChange(of: setInfoModel.setSettings.maxIndex) { newIndex in
            opacityController.triggerEnvelope(forIndex: newIndex) // Aangepast om de correcte methodeaanroep te gebruiken
        }
        .frame(width: width, height: height)
    }
}

