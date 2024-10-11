//
//  eMotionApp.swift    
//  eMotion
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI
import AVFoundation
import Combine
import AudioKit

@main
struct eMotionApp: App {
    
    init() {
        #if os(iOS)
            do {
                Settings.bufferLength = .short

                let deviceSampleRate = AVAudioSession.sharedInstance().sampleRate
                if deviceSampleRate > Settings.sampleRate {
                    // Update sampleRate to 48_000. Default is 44_100.
                    Settings.sampleRate = deviceSampleRate
                }

                try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                                options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let err {
                print(err)
            }
        #endif
    }
    
    //We need a set loaded into ram and userSettings
//    let instrumentSet = AppUtils.loadInstrumentSet(json: "SE-set-default.json")
    let instrumentSet = AppUtils.loadInstrumentSet(json: "Loader.json")
    
//    @State public var sessionDisplay: SessionDisplay = .home
    @State public var sessionDisplay: SessionDisplay = .pro
//    @State public var sessionDisplaySub: SessionDisplay = .page01
    @State public var sessionDisplaySub: SessionDisplay = .pro
    
    var startViewModel = StartViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainViewContainer(
                viewModel: MainViewModel(
                    mainState: MainViewState(
                        setSettings: AppUtils.setSettings(
                            instrumentSet: instrumentSet
                        ),
                        imageDifference: ImageDifference(
                            instrumentsSet: instrumentSet
                        ),
                        currentInstrumentsSet: instrumentSet,
                        semActive: SeMActive()
                    ),
                    conductor: Conductor(set: instrumentSet),
                    leveling: Leveling(),
                    partFeedback: PartFeedback(instrumentsSet: instrumentSet)
                ),
                sessionDisplay: $sessionDisplay
            )
            .statusBar(hidden: true)
            .preferredColorScheme(.dark)
            .environmentObject(UserSettings.shared)
            .environmentObject(startViewModel)
        }
    }
}
