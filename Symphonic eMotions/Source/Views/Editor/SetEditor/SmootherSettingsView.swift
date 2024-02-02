//
//  smootherSettingsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 02/02/2024.
//

import SwiftUI

struct SmootherSettingsView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State var localSmootherVersion: Int
    @State var showConfirmationAlert = false
    
    var body: some View {
        HStack{
            Picker(
                "Smoother",
                selection: Binding(
                    get: {
                        setInfoModel.setSettings.smootherVersion
                    },
                    set: { value in
                        localSmootherVersion = value
                        showConfirmationAlert = true
                    }
                )
            ) {
                ForEach( 1...2, id: \.self){
                    Text("Version \($0)")
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
                    message: Text("Set all Ramp Up and Ramp Down settings to smoother value default?"),
                    primaryButton: .destructive(Text("OK")) {
                        setInfoModel.setSettings.smootherVersion = localSmootherVersion
                        setInfoModel.setSettings.resetRampSetting(version: localSmootherVersion)
                    },
                    secondaryButton: .cancel(Text("Do not change"))
                )
            }
        }
    }
}
