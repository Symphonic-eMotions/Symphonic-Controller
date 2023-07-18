//
//  SpriteKitTransport.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 07/02/2023.
//

import SwiftUI

struct SpriteKitTransport: View {
    
    @AppStorage(UserDefaultsKeys.isSetPlaying) var isSetPlaying: Bool = false
    
//    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    let transportHeigth: CGFloat
    @State private(set) var localTempo: Int = 0
    
    init(
//        mainViewModel: MainViewModel,
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        sessionDisplaySub: Binding<SessionDisplay>,
        transportHeigth: CGFloat
    ) {
//        self.mainViewModel = mainViewModel
        self.setInfoModel = setInfoModel
        self._sessionDisplay = sessionDisplay
        self._sessionDisplaySub = sessionDisplaySub
        self.transportHeigth = transportHeigth
    }
    
    var body: some View {
        
        HStack{
            
            HStack{
                
                EMButton(action: {
                    
                    setInfoModel.tapStopAudioEngine()
                    //Check if back is playlists or set info
                    let parentDirectoryName = setInfoModel.setSettings.setURL.deletingLastPathComponent().lastPathComponent
                    if BuildSettings.Playlists(rawValue: parentDirectoryName) != nil {
                        sessionDisplay = .playlists
                        sessionDisplaySub = .playlists
                    }
                    else {
                        sessionDisplay = .setInfo
                        sessionDisplaySub = .none
                        //We do not want to go to the next set
                        setInfoModel.setSettings.currentPlaylist = .none
                    }
                    
                }, color: .accentColor, isSolid: false, maxWidth: 70) {
                    Image(systemName: "arrowshape.backward")
                }
                
                if setInfoModel.setInfoState.currentInstrumentsSet.hasTempo {
                    
                    EMButton(action: {
                        setInfoModel.tapSetTempoBPMMin()
                        localTempo -= 1
                    }, color: .accentColor, isSolid: false, maxWidth: 70) {
                        Image(systemName: "minus")
                    }
                    
                    EMButton(action: {
                        print("Reset")
                        localTempo = 0
                        setInfoModel.tapSetTempoReset()
                    }, color: .accentColor, isSolid: false, maxWidth: 65) {
                        Text(String(localTempo))
                    }

                    EMButton(action: {
                        setInfoModel.tapSetTempoBPMPlus()
                        localTempo += 1
                    }, color: .accentColor, isSolid: false, maxWidth: 70) {
                        Image(systemName: "plus")
                    }
                }
                
                //Start stop
                EMButton(action: {
                    
                    if isSetPlaying {
                        setInfoModel.tapStopAudioEngine()
                        self.isSetPlaying = false
                        setInfoModel.leveling.pauseLevel = false
                    }
                    else{
                        setInfoModel.tapStartAudioEngine()
                        self.isSetPlaying = true
                    }
                    
                }, color: .accentColor, isSolid: true, maxWidth: 90) {
                    Image(systemName: isSetPlaying ?
                            "stop.fill" :
                            "play.fill")
                }
                
                //Level progress and interface
                LevelView(
                    setInfoModel: setInfoModel
                )
                
                VStack(){
                    
                    VolumeSlider()
                        .frame(width: 200, height: 20)
//                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
//                        .zIndex(100)
                    
//                    OpacitySlider(value: Binding(
//                            get: {playViewModel.playViewState.displayOpacity},
//                            set: { (newval) in
//                                self.playViewModel.playViewState.displayOpacity = newval
//
//                            }
//                        )
//                    )
//                    .frame(width: 200, height: 20)
//                    .padding(.bottom, 2)
//                    .zIndex(100)
                }
            }
        }
    }
}
