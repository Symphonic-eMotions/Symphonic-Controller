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
            .preferredColorScheme(.dark)
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
