//
//  SetFileButtonView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 31/01/2024.
//

import SwiftUI

struct SetFileButtonView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    let setFile: SetFile
    @Binding var selectedSet: SetFile?
    @Binding var sessionDisplay: SessionDisplay
    @Binding var setInfoLocalState: SetInfoLocalState
    @State private var showDisabled: Bool = false
    var setInfoModel: SetInfoModel
    var body: some View {
        Button(action: {}) {
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    HStack{
                        Text(setFile.name)
                            .foregroundColor(selectedSet == setFile ? .white : .primary)
                            .font(.headline)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.vertical, 4.0)
            .padding(.leading, 4.0)
            .background( showDisabled ? Color.red.opacity(0.5) : (selectedSet == setFile ? Color.accentColor : .secondary))
            .cornerRadius(10.0)
        }
        .onTapGesture {
            
            userSettings.isCapturingRunning = false
            
            selectedSet = setFile
            setInfoModel.tapStopAudioEngine()
            
            setInfoLocalState.setName = setFile.name
            setInfoLocalState.setConfig = setFile.url.lastPathComponent
            setInfoLocalState.setURL = setFile.url.absoluteString
            
            sessionDisplay = .setInfo
        }
    }
}
