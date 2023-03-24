//
//  FullView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 04/07/2022.
//

import SwiftUI
import Combine
import AudioKit
//import HomeKit

struct FullViewState {
    let currentInstrumentSet: InstrumentsSet
    let buildSettings: BuildSettings
}

final class FullViewModel: ObservableObject {
    
    let setCollections: Sets
    
    @Published var state: FullViewState
    var currentInstrumentSetIsChanged: (InstrumentsSet) -> Void
    var conductor: Conductor
    
    init(
        setCollections: Sets = AppUtils.loadSets(json: "SE-sets-muur"),
        state: FullViewState,
        currentInstrumentSetIsChanged: @escaping (InstrumentsSet) -> Void,
        conductor: Conductor
    ) {
        self.setCollections = setCollections
        self.state = state
        self.currentInstrumentSetIsChanged = currentInstrumentSetIsChanged
        self.conductor = conductor
    }
    
    func fillAnimationKeep(setCollections: Sets) -> [Int: Bool] {
        
        var animationKeep: [Int : Bool] = [:]
        
        setCollections.sets.forEach{
            animationKeep[Int($0.id)!] = false
        }
        
        return animationKeep
    }
}



struct FullView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @ObservedObject var fullViewModel: FullViewModel
    
//    @EnvironmentObject var homeKitStore: HomeKitManager
    
    var body: some View {
        
        ZStack(alignment: .center){
            
            //Why is this here? To force the user privacy camera access dialog on startup
            //When it;s done later, the priviliges willl not be remebered between set switches
            VideoPreviewViewRepresetable(
                playViewModel: playViewModel
            )
            
            FullHomeView(fullHomeViewModel: FullHomeViewModel(
                state: FullHomeViewState(
                    setCollections: fullViewModel.setCollections,
                    currentInstrumentSet: fullViewModel.state.currentInstrumentSet,
                    animationKeep: fullViewModel.fillAnimationKeep(setCollections: fullViewModel.setCollections)
                ),
                rowSelected: fullViewModel.currentInstrumentSetIsChanged,
                conductor: fullViewModel.conductor
            ))
//            .environmentObject(homeKitStore)
            
//            HomeKitView().environmentObject(homeKitStore)
            
        }
        
        
    }
}
