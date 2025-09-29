//
//  HomeView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/09/2024.
//

import SwiftUI

struct HomeView: View {
    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay
    @ObservedObject var setInfoModel: SetInfoModel

    var body: some View {
        VStack {
            // Check the current sub-display and show the appropriate view
            switch sessionDisplaySub {
            case .page03:
                LightView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub
                )

            case .page04:
                MovementView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub
                )

            default:
                IntroductionView(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub
                )
            }
        }
        .onAppear {
            print("HomeView appeared with sessionDisplaySub: \(sessionDisplaySub)")
        }
        .onChange(of: sessionDisplaySub) { newValue in
            print("HomeView updated with sessionDisplaySub: \(newValue)")
        }
    }
}
