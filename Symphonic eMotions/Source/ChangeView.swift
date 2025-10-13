////
////  ChangeView.swift
////  Symphonic eMotions Pro
////
////  Created by Frans-Jan Wind on 31/05/2023.
////
//
//import AVFoundation
//import SwiftUI
//
//struct ChangeView: View {
//    // We need background audio for sampler loading, so we create some background audio!
//    @Environment(\.scenePhase) private var scenePhase
//    @EnvironmentObject var userSettings: UserSettings
//
//    @Binding var sessionDisplay: SessionDisplay
//    @Binding var sessionDisplaySub: SessionDisplay
//
//    @StateObject private var audioPlayer = AudioPlayer()
//    @State private var showingAlert = false
//
//    var body: some View {
//        Text("")
//            .frame(height: 0)
//            .onChange(of: scenePhase) { newScenePhase in
//                switch newScenePhase {
//                case .background:
//                    userSettings.showPartEditor = false
//                    audioPlayer.enableBackground()
//                case .inactive:
//                    userSettings.showPartEditor = false
//                    print("App is inactive")
//                case .active:
//                    print("App is active sessioDisplay: \(sessionDisplay)")
//                @unknown default:
//                    print("Unknown scenePhase")
//                }
//            }
//    }
//}
//
//class AudioPlayer: ObservableObject {
//    var autoSound: AVAudioPlayer!
//
//    func enableBackground() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
//            print("Playback OK")
//            try AVAudioSession.sharedInstance().setActive(true)
//            print("Session is Active")
//        } catch {
//            print(error)
//        }
//    }
//
//    func isAudioPlaying() -> Bool {
//        return autoSound?.isPlaying ?? false
//    }
//
//    func fadeOutAndStop() {
//        let fadeDuration = 1.0 // Use your desired fade duration
//        autoSound.setVolume(0, fadeDuration: fadeDuration)
//
//        // After the fade duration, stop the player
//        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
//            self.autoSound.stop()
//            self.autoSound.currentTime = 0 // Optional: set the player back to the start
//        }
//    }
//}
