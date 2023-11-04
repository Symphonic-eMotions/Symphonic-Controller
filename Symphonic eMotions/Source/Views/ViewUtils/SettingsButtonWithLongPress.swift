//
//  EMButton.swift
//  EMButton
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct SettingsButtonWithLongPress: View {
    
    @AppStorage(UserDefaultsKeys.showPartEditor) var showPartEditor: Bool = false
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    let color: Color = .accentColor
    var isSolid: Bool = false
    
    @State private var presentSettingSheet = false
    
    var body: some View {
        
        Button(action: {
            // ignore
        }) {
            Image(systemName: "gear")
        }
        .padding(.horizontal)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .font(.system(size: 17).weight(.semibold))
        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(color))
        .foregroundColor(isSolid ? .white : color)
        .background(isSolid ? color : .clear)
        .cornerRadius(8.0)
        //Activate Track and Part editor
        .simultaneousGesture(LongPressGesture(minimumDuration: 1).onEnded { _ in
            showPartEditor.toggle()
            if showPartEditor == true {
                setInfoModel.leveling.pauseLevel = true
            }
        })
        //Show the settings sheet
        .simultaneousGesture(TapGesture().onEnded {
            presentSettingSheet.toggle()
        })
        //Present sheet
        .sheet(isPresented: $presentSettingSheet) {
            SettingsSheetView(
                setInfoModel: setInfoModel,
                showingSheet: $presentSettingSheet
                
            )
        }
    }
}
