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
            
            Text("BPM")
            .frame(width: 40)
            .padding(.leading)
            
            TextField("BPM", text: $setInfoModel.setSettings.bpmAsString)
//            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 85)
            
            if !setInfoModel.setInfoState.currentInstrumentsSet.hasTempo {
                Text("Fixed tempo set (Stems)")
            }
        }
    }
}
