//
//  ChangeView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 31/05/2023.
//

import SwiftUI
import AVFoundation

struct ChangeView: View {
    
    //We need background audio for sampler loading, so we create some background audio!
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some View {
        
        Text("")
        .frame(height: 0)
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .background:
                print("App is in background")
                if !audioPlayer.isAudioPlaying() {
                    audioPlayer.playTrudy()
                }
            case .inactive:
                print("App is inactive")
            case .active:
                print("App is active")
                if audioPlayer.isAudioPlaying() {
                    audioPlayer.fadeOutAndStop()
                }
            @unknown default:
                print("Unknown")
            }
        }
    }
}

class AudioPlayer: ObservableObject {
    
    var autoSound: AVAudioPlayer!
    
    func playTrudy() {
        print("playTrudy")
        
        let sounds = ["Trudy01"]
        
        if let randomSound = sounds.randomElement() {
            print("Random sound selected: \(randomSound)")
            if let path = Bundle.main.path(forResource: "Samples/" + randomSound, ofType: "aiff") {
                print("Path exists: \(path)")
                let url = URL(fileURLWithPath: path)
                print("URL is valid: \(url)")
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
                    print("Playback OK")
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("Session is Active")
                } catch {
                    print(error)
                }
                
                do {
                    autoSound = try AVAudioPlayer(contentsOf: url)
                    autoSound?.prepareToPlay()
                    autoSound?.play()
                    autoSound?.volume = 0.5
                } catch {
                    print("Error: could not play sound: \(error)")
                }
            } else {
                print("Failed to get path for resource.")
            }
        } else {
            print("Failed to select random sound.")
        }
    }
    
    func isAudioPlaying() -> Bool {
        return autoSound?.isPlaying ?? false
    }
    
    func fadeOutAndStop() {
        let fadeDuration = 1.0  // Use your desired fade duration
        autoSound.setVolume(0, fadeDuration: fadeDuration)
        
        // After the fade duration, stop the player
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
            self.autoSound.stop()
            self.autoSound.currentTime = 0  // Optional: set the player back to the start
        }
    }
    
}

