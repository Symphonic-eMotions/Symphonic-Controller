//
//  StartView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/05/2023.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    
    let url: URL
    @State var isPlaying: Bool = false
    @State private var player = AVPlayer()
    
//    var body: some View {
//        VideoPlayer(player: AVPlayer(url: url))
//            .frame(height: 400)
//        
//    }
    
    var body: some View {
        ZStack {
            
            VideoPlayer(player: player)
                .frame(height: 400)
            
            if !isPlaying {
                        
                // Invisible view to capture taps
                Color.black
                    .frame(width: 711, height: 400) // Scaled dimensions
                    .contentShape(Rectangle())  // Makes the entire area tappable
                    .opacity(0.5)
                    .allowsHitTesting(true)
                
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        self.player.play()
                        isPlaying = true
                    }
            }
        }
        .onAppear {
            self.player = AVPlayer(url: url)
        }
    }
}

struct DemoView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var userSettings: UserSettings
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    var body: some View {
        
        VStack{
            
            Spacer().frame(height:50)
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
            Spacer().frame(height:35)
            
            HStack{
                
                if let url = Bundle.main.url(
                    forResource: "SeM-Demo-02",
                    withExtension: "mp4",
                    subdirectory: "Videos") {
                    
                        VideoPlayerView(url: url)
                                            
                } else {
                    Text("Video file not found")
                }
                
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
