//
//  SelectGrid.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 31/03/2023.
//

import SwiftUI

struct SelectGrid: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State var localGridRow: Int
    
    var body: some View {
        
        HStack{
            Picker(
                "Skins",
                selection: Binding(
                    get: {
                        setInfoModel.setSettings.gridRows
                    },
                    set: { value in
                        localGridRow = value
                        setInfoModel.setSettings.gridRows = value
                        setInfoModel.setSettings.gridColumns = value
                        //Reset all grid related arrays
                        setInfoModel.setSettings.resetGridArrays(cells: value*value)
                    }
                )
            ) {
                ForEach( 2...4, id: \.self){
                    Text("Grid \($0) x \($0)")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
//            .fixedSize()
            .padding(.leading)
            .padding(.trailing)
            .foregroundColor(.white)
            .accentColor(Color.accentColor)
        }
    }
}
