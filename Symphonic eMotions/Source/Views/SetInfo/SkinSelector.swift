//
//  SkinSelector.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 31/03/2023.
//

import SwiftUI

struct SkinSelector: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    var availableSkins: [SessionDisplay]
    @State var localSessionDisplay: SessionDisplay
    
    init(
        setInfoModel: SetInfoModel,
        availableSkins: [SessionDisplay],
        loadSessionDisplay: SessionDisplay
    ){
        self.setInfoModel = setInfoModel
        self.availableSkins = availableSkins
        self.localSessionDisplay = loadSessionDisplay
    }
    
    var body: some View {
        
        HStack{
            Picker(
                "Skins",
                selection: Binding(
                    get: {
                        localSessionDisplay
                    },
                    set: { value in
                        localSessionDisplay = value
                        setInfoModel.setInfoLocalState.loadSessionDisplay = value
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
}
