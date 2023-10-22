//
//  PlayListsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 04/05/2023.
//

import SwiftUI

struct PlayListsView: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "PlayListsView"
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @EnvironmentObject var fileController: FileController

    var body: some View {
        HStack(spacing: 10) {
            PlaylistView(
                setInfoModel: setInfoModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub,
                viewModel: PlaylistViewModel(playlist: BuildSettings.Playlists.minimal)
            )
            PlaylistView(
                setInfoModel: setInfoModel,
                sessionDisplay: $sessionDisplay,
                sessionDisplaySub: $sessionDisplaySub,
                viewModel: PlaylistViewModel(playlist: BuildSettings.Playlists.person)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .padding(10)
    }
}


