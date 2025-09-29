//
//  DemoView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/05/2023.
//

import AVKit
import SwiftUI

struct DemoView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var userSettings: UserSettings
    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            HStack {
                Image("LogoColor")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .cornerRadius(10)
                    .padding(.trailing)

                Text("Symphonic eMotions")
                    .font(.largeTitle)
                    .scaleEffect(1.2)
                    .fontWeight(.regular)
                    .padding(.leading, 40)
            }
            Spacer().frame(height: 35)

            HStack {
//                if let url = Bundle.main.url(
//                    forResource: "SeM-Demo-03",
//                    withExtension: "mp4",
//                    subdirectory: "Videos") {
//
//                        VideoPlayerView(url: url)
//
//                } else {
//                    Text("Video file not found")
//                }

//                Text(NSLocalizedString("Welcome home", comment: ""))
//                    .font(.title)
//                    .scaleEffect(1.1)
//                    .padding(.top, 70)
//                    .padding(.trailing, 100)
//                    .padding(.leading, 100)
//
            }
            Spacer()

            FooterView(userSettings: userSettings)
        }
    }
}
