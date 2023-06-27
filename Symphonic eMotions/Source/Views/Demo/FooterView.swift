//
//  FooterView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/06/2023.
//

import SwiftUI

struct FooterView: View {
    @State private var isEditing = false
    @State private var inputUserCode: String = ""
    @AppStorage("userCode") private var userCodeRaw: String = UserCode.none.rawValue
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
                    self.isEditing.toggle()
                }
            if isEditing {
                TextField("Enter user code", text: $inputUserCode, onCommit: {
                    if let userCode = UserCode(rawValue: inputUserCode) {
                        // `inputUserCode` matches a `UserCode` case, and `userCode` is now that case
                        // Store it in userCodeRaw
                        userCodeRaw = userCode.rawValue
                        isEditing = false
                    } else {
                        // `inputUserCode` does not match any `UserCode` case
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
