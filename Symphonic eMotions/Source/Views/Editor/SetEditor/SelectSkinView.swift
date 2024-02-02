//
//  DefaultSkin.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 13/04/2023.
//

import SwiftUI

struct SelectSkinView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    var availableSkins: [SessionDisplay] = [.swiftUI,.spriteKit]
    @State var localSessionDisplay: SessionDisplay
    
    init(
        setInfoModel: SetInfoModel
    ){
        self.setInfoModel = setInfoModel
        _localSessionDisplay = State(initialValue: setInfoModel.setSettings.defaultSkin)
    }
    
    var body: some View {
        
        Picker(
            "Skins",
            selection: Binding(
                get: {
                    localSessionDisplay
                },
                set: { value in
                    localSessionDisplay = value
                    setInfoModel.setSettings.defaultSkin = value
                }
            )
        ) {
            ForEach( availableSkins, id: \.self){
                Text($0.title)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .fixedSize()
        .padding(.vertical, 10.0)
        .padding(.leading, 10.0)
        .foregroundColor(.white)
        .accentColor(Color.accentColor)
        
    }
}
