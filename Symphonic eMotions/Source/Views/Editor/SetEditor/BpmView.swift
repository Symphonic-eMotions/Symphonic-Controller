//
//  BpmView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 01/04/2023.
//

import SwiftUI

struct BpmView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        
        HStack{
            
            Text("\(Int(setInfoModel.setSettings.bpm))")
                .frame(width: 40)
                .padding(.leading)
            
            Slider(value: $setInfoModel.setSettings.bpm, in: 40...200, step: 1)
                .padding()
        }
        
        if !setInfoModel.setInfoState.currentInstrumentsSet.hasTempo {
            Text("Fixed tempo set (Stems)")
        }
    }
}

