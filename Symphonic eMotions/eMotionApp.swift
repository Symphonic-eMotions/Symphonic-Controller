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
    let synthesizer = AVSpeechSynthesizer()
    
    //We need a set loaded into ram and @AppStorage
    let instrumentSet = AppUtils.loadInstrumentSet(json: "SE-set-default.json")
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "SE-set-default.json"
    
//    let sessionSettings = AppUtils.setSessionSetting()
    
    //Started as view controller, now used is view updater
    let buildSettings = BuildSettings(
        isAdvanced: false,
        instrumentPartEditor: false,
        isMasterTrack: false
    )
    
    @State public var sessionDisplay: SessionDisplay = .pro
    @State public var sessionDisplaySub: SessionDisplay = .demo
    
    init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: MainViewModel(
                    mainState: MainViewState(
//                        sessionSettings: sessionSettings,
                        setSettings: AppUtils.setSettings(
                            instrumentSet: instrumentSet
//                            ,
//                            sessionSettings: sessionSettings
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
        .onChange(of: scenePhase) { phase in
            
            if phase == .active {
                synthesizer.stopSpeaking(at: .word)
            }
            
            else if phase == .background {
                
                if !synthesizer.isSpeaking {
                    
                    let trudy = AVSpeechUtterance(string: "Greetings, this message is conveyed by your system administrator. You may be wondering about the reason behind this communication. This necessity arises because the Apple Sampler we are using, only has the capability to reload audio samples when the 'background audio allowed' setting is enabled. When it's not turned on all you get are sinusses for audio output. Due to this setting the application can only be approved by Apple when it hears an ongoing background sound. Therefore, this message is essential for that confirmation process. We apologize for any inconvenience this may cause.")
                    trudy.voice = AVSpeechSynthesisVoice(language: "en-AU")
                    trudy.rate = 0.49
                    trudy.pitchMultiplier = 1.25
                    synthesizer.speak(trudy)
                }
            }
        }
    }
}
