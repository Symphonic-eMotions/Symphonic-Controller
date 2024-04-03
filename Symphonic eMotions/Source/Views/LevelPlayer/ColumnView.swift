//
//  ColumnView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 03/04/2024.
//

import SwiftUI

struct ColumnView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var columnOpacityController: ColumnOpacityController
    
    let rows: Int
    let columns: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        
        let columnsGridItem: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: self.columns)
        let totalHorizontalSpacing = CGFloat(self.columns - 1) * 20
        let columnWidth = (width - totalHorizontalSpacing - 40) / CGFloat(self.columns)
        
        LazyVGrid(columns: columnsGridItem, spacing: 20) {
            ForEach(0..<self.columns, id: \.self) { columnIndex in
                let color: Color = [.green, .yellow, .orange, .purple][columnIndex % 4]
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 2)
                    .background(color.opacity(0.2))
                    .frame(width: columnWidth, height: height - 40) // Trek de padding van de totale hoogte af
                    .opacity(columnOpacityController.columnOpacities[columnIndex])
            }
        }
        .padding(20)
        .onChange(of: setInfoModel.setSettings.maxIndex) { newIndex in
            let columnIndex = columnIndex(
                forCellIndex: newIndex,
                inGridWithRows: self.rows,
                columns: self.columns
            )
            columnOpacityController.triggerColumnEnvelope(forColumn: columnIndex)
        }
        .frame(width: width, height: height) // Gebruik de externe afmetingen voor het bepalen van de grootte van de ColumnView
    }
    
    func columnIndex(forCellIndex cellIndex: Int, inGridWithRows rows: Int, columns: Int) -> Int {
        if cellIndex == -1 {
            return -1
        }
        
        return cellIndex % columns
    }
}
