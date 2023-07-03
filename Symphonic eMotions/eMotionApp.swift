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
//    let instrumentSet = AppUtils.loadInstrumentSet(json: "SE-set-default.json")
    let instrumentSet = AppUtils.loadInstrumentSet(json: "Introductie.json")
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introductie.json"
    @AppStorage(UserDefaultsKeys.levelSpeed) var levelSpeed: Double = 1
    @AppStorage(UserDefaultsKeys.sensitivity) var sensitivity: Double = 0.8
        
    //Started as view controller, now used is view updater
    let buildSettings = BuildSettings(
        isAdvanced: false,
        instrumentPartEditor: false,
        isMasterTrack: false
    )
    
    @State public var sessionDisplay: SessionDisplay = .home
    @State public var sessionDisplaySub: SessionDisplay = .page01
    
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
