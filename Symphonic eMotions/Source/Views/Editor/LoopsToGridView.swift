//
//  LoopsToGridView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 04/04/2023.
//

import SwiftUI


struct GridCell: View {
    let value: Int
    
    var body: some View {
        ZStack {
            if value == 1 {
                Color.blue
            }
            else if value == 2{
                Color.green
            }
            Text("\(value)")
        }
        .frame(width: 50, height: 50)
    }
}

struct LoopsToGridView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State var key: String
    
    var body: some View {
        
        if let cells: [Int] = setInfoModel.setSettings.tracks[key]?.loopsToGrid {
            
            let gridRows: Int = setInfoModel.setSettings.gridRows
            let gridColumns: Int = setInfoModel.setSettings.gridColumns
            
            VStack(spacing: 0) {
                ForEach(0..<gridRows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<gridColumns, id: \.self) { column in
                            let index = row * 3 + column
                            GridCell(value: cells[index])
                        }
                    }
                }
            }
        }
    }
}
