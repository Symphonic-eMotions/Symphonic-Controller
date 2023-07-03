//
//  PlayGridView.swift
//  GridView
//
//  Created by Frans-Jan Wind on 18 october 2022
//

import SwiftUI

struct EditGridView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        VStack {
            
            ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.rows, id: \.self) { row in
                HStack {
                    ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.columns, id: \.self) { column in
                        ZStack {
                            RoundedRectangle(cornerRadius: 7.0)
                            .fill(
                                setInfoModel.partColor(
                                    row: row,
                                    column: column
                                )
                            )
                            .overlay(RoundedRectangle(cornerRadius: 7.0).stroke(Color("GridBorderColor")))
                            .cornerRadius(7.0)
                            .hueRotation(.degrees(setInfoModel.partDegree(
                                row: row,
                                column: column
                            )))
                        }

                        .onTapGesture {
                            setInfoModel.tapOnCell(row: row, column: column)
                        }
                    }
                }
            }
        }
        .aspectRatio(1.77777, contentMode: .fit)
    }
}
