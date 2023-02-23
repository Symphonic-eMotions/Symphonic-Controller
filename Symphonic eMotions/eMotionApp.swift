//
//  eMotionApp.swift    
//  eMotion
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI

@main
struct eMotionApp: App {
    
    let setCollection: Sets = AppUtils.loadSets(json: "SE-sets")
    
    let instrumentSet = AppUtils.loadInstrumentSet(json: "SE-set-default")
    
    let sessionSettings = AppUtils.setSessionSetting()
    
    let buildSettings = BuildSettings(
        mainSettings: .zorg,
        activeView: .homeView,
        isAdvanced: false,
        instrumentPartEditor: false,
        isMasterTrack: false
    )
    

    
    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: MainViewModel(
                    mainState: MainViewState(
                        sessionSettings: sessionSettings,
                        setSettings: AppUtils.setSettings(
                            instrumentSet: instrumentSet
                        ),
                        imageDifference: ImageDifference(
                            instrumentsSet: instrumentSet,
                            sessionSetting: sessionSettings
                        ),
                        currentInstrumentsSet: instrumentSet,
                        buildSettings: buildSettings
                    ),
                    conductor: Conductor(set: instrumentSet),
                    leveling: Leveling(),
                    partFeedback: PartFeedback(instrumentsSet: instrumentSet)
                ),
                mainViewUpdate: buildSettings.activeView
            )
        }
    }
}
