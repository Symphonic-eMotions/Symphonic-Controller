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
    
    @AppStorage(UserDefaultsKeys.showPartEditor) var showPartEditor: Bool = false
    
    @Binding var sessionDisplay: SessionDisplay
    @Binding var sessionDisplaySub: SessionDisplay
    
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var showingAlert = false
    
    var body: some View {
        
        Text("")
        .frame(height: 0)
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .background:
                AnalyticsAction.appBackground.logEvent(sessionDisplay: sessionDisplay)
                showPartEditor = false
                audioPlayer.enableBackground()
            case .inactive:
                showPartEditor = false
                print("App is inactive")
            case .active:
                AnalyticsAction.appForeground.logEvent(sessionDisplay: sessionDisplay)
                print("App is active sessioDisplay: \(sessionDisplay)")
            @unknown default:
                print("Unknown scenePhase")
            }
        }
//        .alert(isPresented: $showingAlert) {
//            Alert(
//                title: Text(NSLocalizedString("Resume or start over", comment: "")),
//                message: Text(NSLocalizedString("Resume text", comment: "")),
//                primaryButton: .default(Text(NSLocalizedString("Resume", comment: ""))),
//                secondaryButton: .default(Text(NSLocalizedString("Opnieuw beginnen", comment: ""))) {
//                    
//                    //TODO: connect to engine
//                    print("Stop ENGINE and start over!")
//                    
//                    sessionDisplay = .home
//                    sessionDisplaySub = .page01
//                }
//            )
//        }
    }
}

class AudioPlayer: ObservableObject {
    
    var autoSound: AVAudioPlayer!
    
    func enableBackground(){
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
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

