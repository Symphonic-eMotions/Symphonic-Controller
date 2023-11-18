//
//  FooterView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import SwiftUI

struct FooterView: View {
    
    @ObservedObject var userSettings: UserSettings
    @State private var isEditing = false
    @State private var inputUserCode: String = ""
    @State private var showingAlert = false

    var body: some View {
        HStack {
            
            Spacer()
            
            Image("LogoColor")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .cornerRadius(10)
                .onLongPressGesture {
                    AnalyticsAction.unlockCreator.logEvent(sessionDisplay: .none)
                    self.isEditing.toggle()
                }
            if isEditing {
                TextField("Enter user code", text: $inputUserCode, onCommit: {
                    if let userCode = UserCode(rawValue: inputUserCode) {
                        userSettings.userCode = userCode
                        isEditing = false
                    } else {
                        // Show an alert
                        showingAlert = true
                    }
                })
                .textFieldStyle(.roundedBorder)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Invalid User Code"),
                        message: Text("The code you entered does not match any user code."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            else {
                VStack(alignment: .leading) {
                    Text("Symphonic eMotions")
                        .font(.headline)
                    Text("© 2023")
                        .font(.subheadline)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
}

