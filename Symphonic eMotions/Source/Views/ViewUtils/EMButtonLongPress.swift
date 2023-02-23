//
//  EMButton.swift
//  EMButton
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct EMButtonLongPress: View {
    
    @ObservedObject var viewModelPlayerControls: PlayerControlsViewModel
    
    @Binding var mainViewUpdate: BuildSettings.ActiveView
    
    let color: Color = .accentColor
    var isSolid: Bool = false
    
    @State private var presentAlert = false
    
    init(viewModelPlayerControls: PlayerControlsViewModel, mainViewUpdate: Binding<BuildSettings.ActiveView>){
        self.viewModelPlayerControls = viewModelPlayerControls
        self._mainViewUpdate = mainViewUpdate
    }
    
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
        .simultaneousGesture(LongPressGesture(minimumDuration: 1).onEnded { _ in
            print("Secret Long Press Action!")
            viewModelPlayerControls.tapPartFeedbackButton()
        })
        .simultaneousGesture(TapGesture().onEnded {
            print("Boring regular tap")
//            if viewModelPlayerControls.conductor.isConductorPlayingSubject.value {
//                viewModelPlayerControls.conductor.togglePlayEngineAndTracks(currentSetLevel: 0)
//            }
//            presentAlert = true
            viewModelPlayerControls.tapSettingsButton()
        })
//        .alert(
//            "Calibreren",
//            isPresented: $presentAlert,
//            actions: {
//                Button("Ga naar calibreren", action: {
//                    self.mainViewUpdate = .calibration
//                })
//                Button("Cancel", role: .cancel, action: {})
//            },
//            message: {
//                Text("Ga naar calibreren om de gevoeligheid van de app aan te passen")
//            }
//
//        )
    }
    
}

struct EMButtonLongPress_Previews: PreviewProvider {
    static var previews: some View {
        EMButton(action: {}, color: .accentColor) {
            Text("Test")
        }
    }
}
