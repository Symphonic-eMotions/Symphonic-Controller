//
//  eMotionApp.swift    
//  eMotion
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI
import AVFoundation

@main
struct eMotionApp: App {
    
    //We need background audio for sampler loading, so we create some background audio!
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var audioPlayer = AudioPlayer()
    
    //We need a set loaded into ram and @AppStorage
    let instrumentSet = AppUtils.loadInstrumentSet(json: "SE-set-default.json")
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "SE-set-default.json"
    @AppStorage(UserDefaultsKeys.levelSpeed) var levelSpeed: Double = 1
    @AppStorage(UserDefaultsKeys.sensitivity) var sensitivity: Double = 0.8
        
    //Started as view controller, now used is view updater
    let buildSettings = BuildSettings(
        isAdvanced: false,
        instrumentPartEditor: false,
        isMasterTrack: false
    )
    
    @State public var sessionDisplay: SessionDisplay = .pro
    @State public var sessionDisplaySub: SessionDisplay = .demo
    
    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: MainViewModel(
                    mainState: MainViewState(
                        setSettings: AppUtils.setSettings(
                            instrumentSet: instrumentSet
                        ),
                        imageDifference: ImageDifference(
                            instrumentsSet: instrumentSet
                        ),
                        currentInstrumentsSet: instrumentSet,
                        buildSettings: buildSettings
                    ),
                    conductor: Conductor(set: instrumentSet),
                    leveling: Leveling(),
                    partFeedback: PartFeedback(instrumentsSet: instrumentSet)
                ),
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub
            )
            .statusBar(hidden: true)
        }
        
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .background:
                print("App is in background")
                
//                if !audioPlayer.isAudioPlaying() {
//                    audioPlayer.playTrudy()
//                }
                
            case .inactive:
                print("App is inactive")
                
//                if !audioPlayer.isAudioPlaying() {
//                    audioPlayer.playTrudy()
//                }
                
            case .active:
                print("App is active")
//                if audioPlayer.isAudioPlaying() {
//                    audioPlayer.fadeOutAndStop()
//                }
            @unknown default:
                print("Unknown")
            }
        }
    }
    
//    func speak() {
//
//        let trudy = AVSpeechUtterance(string: "Greetings, this message is conveyed by your system administrator. You may be wondering about the reason behind this communication. This necessity arises because the Apple Sampler we are using, only has the capability to reload audio samples when the 'background audio allowed' setting is enabled. When it's not turned on all you get are sinusses for audio output. Due to this setting the application can only be approved by Apple when it hears an ongoing background sound. Therefore, this message is essential for that confirmation process. We apologize for any inconvenience this may cause.")
//
//        if let voice = AVSpeechSynthesisVoice(language: "en-AU") {
//            trudy.voice = voice
//            trudy.rate = 0.49
//            trudy.pitchMultiplier = 1.25
//            autoVoice.speak(trudy)
//        }
//    }
    
    
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
                    autoSound = try AVAudioPlayer(contentsOf: url)
                    autoSound?.prepareToPlay()
                    autoSound?.play()
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
