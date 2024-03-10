//
//  MainViewContainer.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 03/07/2023.
//

import SwiftUI
import Combine

struct MainViewContainer: View {
    
    @ObservedObject var viewModel: MainViewModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    //Set info page vars from navigation
    @State var setInfoLocalState = SetInfoLocalState()
    
    var body: some View {
                
        MainView(
            viewModel: viewModel,
            setInfoModel: SetInfoModel(
                setInfoLocalState: $setInfoLocalState,
                setSettings: $viewModel.mainState.setSettings,
                imageDifference: $viewModel.mainState.imageDifference,
                setInfoState: SetInfoState(
                    currentInstrumentsSet: viewModel.mainState.currentInstrumentsSet,
                    semActive: viewModel.mainState.semActive,
                    masterTrackStructure: MasterTrackEffectsHelper.masterTrackViewObject(
                        instrumentSet: viewModel.mainState.currentInstrumentsSet,
                        setSettings:  viewModel.mainState.setSettings
                    )
                ),
                currentInstrumentsSetIsChanged: { instrumentsSet in
                    viewModel.currentModelInstrumentsSetChanged(
                        instrumentsSet: instrumentsSet
                    )
                },
                conductor: viewModel.conductor,
                leveling: viewModel.leveling,
                partFeedback: viewModel.partFeedback,
                partFeedbackState: PartFeedbackState()
            ),
            sessionDisplay: $sessionDisplay,
            sessionDisplaySub: $sessionDisplaySub
        )
    }
}
