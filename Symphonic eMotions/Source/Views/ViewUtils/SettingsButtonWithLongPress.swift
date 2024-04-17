//
//  EMButton.swift
//  EMButton
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct SettingsButtonWithLongPress: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplaySub: SessionDisplay
    
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
            AnalyticsAction.settingsLong.logEvent(sessionDisplay: .swiftUI)
            userSettings.showPartEditor.toggle()
            if userSettings.showPartEditor == true {
            }
        })
        //Show the settings sheet
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsAction.settings.logEvent(sessionDisplay: .swiftUI)
            presentSettingSheet.toggle()
        })
        //Present sheet
        .sheet(isPresented: $presentSettingSheet) {
            SettingsSheetView(
                userSettings: userSettings,
                setInfoModel: setInfoModel, 
                sessionDisplaySub: $sessionDisplaySub,
                showingSheet: $presentSettingSheet
                
            )
        }
    }
}
