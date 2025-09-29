//
//  VideoPlayerView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 11/05/2024.
//

import AVKit
import SwiftUI

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
                    .contentShape(Rectangle()) // Makes the entire area tappable
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
