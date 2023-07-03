//
//  PlayGridView.swift
//  GridView
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct PlayGridView: View {
        
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        VStack {
            ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.rows, id: \.self) { row in
                HStack {
                    ForEach(0..<setInfoModel.setInfoState.currentInstrumentsSet.columns, id: \.self) { column in
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 7.0)
                                .fill(Color.black)
                            
                            HStack(spacing: 0.0) {
                                
                                let colorsTypes = setInfoModel.colorTypes(
                                    row: row,
                                    column: column
                                )
                                
                                //Hue rotation needs to be added tp rectangle with corrent partNumber
                                
                                ForEach( colorsTypes, id:\.id) { colorType in
                                    Rectangle().fill(colorType.color)
                                }
                            }
                            
                            .overlay(RoundedRectangle(cornerRadius: 7.0).stroke(Color("GridBorderColor")))
                            .cornerRadius(7.0)
                            
                            //Image("Logo")
                        }
                    }
                }
                
            }
        }.aspectRatio(1.77777, contentMode: .fit)
    }
}
/*
struct PlayGridView_Previews: PreviewProvider {
    static var previews: some View {
        PlayGridView(values: .constant([[]]))
    }
}
 */
