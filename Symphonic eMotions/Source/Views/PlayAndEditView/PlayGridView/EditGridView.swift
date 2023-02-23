//
//  PlayGridView.swift
//  GridView
//
//  Created by Frans-Jan Wind on 18 october 2022
//

import SwiftUI

struct EditGridView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    
    var body: some View {
        VStack {
            
            ForEach(0..<playViewModel.playViewState.currentInstrumentsSet.rows, id: \.self) { row in
                HStack {
                    ForEach(0..<playViewModel.playViewState.currentInstrumentsSet.columns, id: \.self) { column in
                        ZStack {
                            RoundedRectangle(cornerRadius: 7.0)
                            .fill(
                                playViewModel.partColor(
                                    row: row,
                                    column: column
                                )
                            )
                            .overlay(RoundedRectangle(cornerRadius: 7.0).stroke(Color("GridBorderColor")))
                            .cornerRadius(7.0)
                            .hueRotation(.degrees(playViewModel.partDegree(
                                row: row,
                                column: column
                            )))
                        }

                        .onTapGesture {
                            playViewModel.tapOnCell(row: row, column: column)
                        }
                    }
                }
            }
        }
        .aspectRatio(1.77777, contentMode: .fit)
    }
}
