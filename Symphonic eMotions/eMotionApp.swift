//
//  eMotionApp.swift    
//  eMotion
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI
import AVFoundation
import Combine
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct eMotionApp: App {
    
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    //We need a set loaded into ram and @AppStorage
//    let instrumentSet = AppUtils.loadInstrumentSet(json: "SE-set-default.json")
    let instrumentSet = AppUtils.loadInstrumentSet(json: "Introductie.json")
    //Also set in: PlaylistViewModelAND SetListViewModel
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introductie.json"
    @AppStorage(UserDefaultsKeys.levelSpeed) var levelSpeed: Double = 1
    @AppStorage(UserDefaultsKeys.sensitivitySession) var sensitivitySession: Double = 0.8
    @AppStorage(UserDefaultsKeys.showPartEditor) var showPartEditor: Bool = false
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false

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
                        buildSettings: BuildSettings()
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
