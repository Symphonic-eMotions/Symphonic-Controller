//
//  eMotionApp.swift    
//  eMotion
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI

@main
struct eMotionApp: App {
    
    let instrumentSet = AppUtils.loadInstrumentSet(json: "SE-set-default.json")
    
    let sessionSettings = AppUtils.setSessionSetting()
        
    let buildSettings = BuildSettings(
        mainSettings: .composer,
        activeView: .homeView,
        isAdvanced: false,
        instrumentPartEditor: false,
        isMasterTrack: false
    )
    
    @State public var sessionDisplay: SessionDisplay = .pro
    @State public var sessionDisplaySub: SessionDisplay = .start

    
    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: MainViewModel(
                    mainState: MainViewState(
                        sessionSettings: sessionSettings,
                        setSettings: AppUtils.setSettings(
                            instrumentSet: instrumentSet,
                            sessionSettings: sessionSettings
                        ),
                        imageDifference: ImageDifference(
                            instrumentsSet: instrumentSet
                        ),
//                        setCollection: setCollection,
                        currentInstrumentsSet: instrumentSet,
                        buildSettings: buildSettings
                    ),
                    conductor: Conductor(set: instrumentSet),
                    leveling: Leveling(),
                    partFeedback: PartFeedback(instrumentsSet: instrumentSet)
                ),
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub,
                mainViewUpdate: buildSettings.activeView
            )
            .statusBar(hidden: true)
        }
    }
}
