//
//  SelectGrid.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 31/03/2023.
//

import SwiftUI

//Set the grid size of this variation
struct SelectGridSizeView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State var localGridRow: Int
    @State var showConfirmationAlert = false
    
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
                        showConfirmationAlert = true
                        
//                        setInfoModel.setSettings.gridRows = value
//                        setInfoModel.setSettings.gridColumns = value
//                        //Reset all grid related arrays
//                        setInfoModel.setSettings.resetGridArrays(cells: value*value)
                    }
                )
            ) {
                ForEach( 2...4, id: \.self){
                    Text("Grid \($0) x \($0)")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .fixedSize()
            .padding(.leading)
            .padding(.trailing)
            .foregroundColor(.white)
            .accentColor(Color.accentColor)
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Confirmation"),
                    message: Text("Are you sure you want to change the grid size? This will empty all grid locations"),
                    primaryButton: .destructive(Text("OK")) {
                        setInfoModel.setSettings.gridRows = localGridRow
                        setInfoModel.setSettings.gridColumns = localGridRow
                        setInfoModel.setSettings.resetGridArrays(cells: localGridRow * localGridRow)
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
    }
}
