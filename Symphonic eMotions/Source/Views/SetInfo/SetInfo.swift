//
//  SetInfo.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI

struct SetInfoLocalState {
    var setName: String
    var smootherVersion: Int
    //String of document with relative path with extension
    var setConfig: String
    //Path of setting
    var setURL: String
    //Navigation header
    var sideBarHead: String
    
    init(){
        self.setName = "home"
        self.setConfig = ""
        self.setURL = "SetInfoLocalState"
        self.sideBarHead = NSLocalizedString("Welcome", comment: "Header of left navigation bar")
        self.smootherVersion = 0
    }
}

struct SetInfo: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "PlayListsView"
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var isCreator: Bool
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    @Binding public var userPresets: [URL]
    
    
    var body: some View {
        VStack{
            
            //.home is the page on entering app, also accesible by clicking the Sets header in the side bar
            if sessionDisplay == .pro {
                SetInfoHome(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay
                )
            }
            //Set info is also the navigator to saved files within the set
            else if sessionDisplay == .setInfo {
                
                //Here we got the Editor!
                if [.setEditor,.playListEditor].contains(sessionDisplaySub) {
                    
                    Text("Variation \(setInfoModel.setInfoLocalState.setName)")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                    
                    EditorView(
                        setInfoModel: setInfoModel,
                        isCreator: $isCreator,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub
                    ).environmentObject(fileController)
                }
                //Set Info
                else{
                    
                    Text("Set \(setInfoModel.setInfoLocalState.setName)")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                    
                    HStack{
                        Spacer()
                        SetLoadAndPlay(setInfoModel: setInfoModel)
                        .onTapGesture {
                            AnalyticsAction.loadSet.logEvent(sessionDisplay: sessionDisplay)
                            //We do not want to go to the next set
                            setInfoModel.setSettings.currentPlaylist = .none
                            //Load set
                            setInfoModel.tapSetRow(filePath: setInfoModel.setInfoLocalState.setConfig)
                            //Let @AppStorage know what is current
                            currentUrl = setInfoModel.setInfoLocalState.setConfig
                            
                            //Change the View
                            sessionDisplay = setInfoModel.setSettings.defaultSkin
                        }
                        Spacer()
                        //New variation button
                        EMButton(
                            action: {
                                AnalyticsAction.newVariation.logEvent(sessionDisplay: sessionDisplay)
                                setInfoModel.setInfoState.currentInstrumentsSet = AppUtils.loadInstrumentSet(json: setInfoModel.setInfoLocalState.setConfig)

                                if(setInfoModel.setInfoState.currentInstrumentsSet.name != "No Set"){
                                    
                                    let setSetting = AppUtils.setSettings(
                                        instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet
                                    )
                                    //Add new file to document directory
                                    _ = AppUtils.createWorkingFile(
                                        setSettings: setSetting,
                                        instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                                        duplicateLastTrack: false,
                                        asNewFile: true
                                    )
                                    //Reload view
                                    userPresets = fileController.getContentsOfDirectory()
                                }
                            }, color: .orange, isSolid: true, maxWidth: 170, height: 35
                        ){
                            Text(NSLocalizedString("New variation", comment: ""))
                        }
                        .frame(width: 170, height: 50)
                        Spacer()
                    }
                    
                    HStack{
                        Image(systemName: setInfoModel.setInfoLocalState.smootherVersion == 2 ?
                              "b.circle.fill" : "a.circle.fill")
                        .foregroundColor(setInfoModel.setInfoLocalState.smootherVersion == 2 ?
                            .orange : .clear)
                        .font(.system(size: 24))
                        
                        Text( setInfoModel.setInfoLocalState.smootherVersion == 2 ?
                            NSLocalizedString("smoother2", comment: "") :
                            ""
                        )
                        .foregroundColor(setInfoModel.setInfoLocalState.smootherVersion == 2 ?
                            .orange : .clear)
                        Spacer()
                        
                    }.padding()
                    
                    Spacer(minLength: 20)
                   
                    ScrollView {
                        
                        SavedSetsList(
                            setInfoModel: setInfoModel,
                            sessionDisplay: $sessionDisplay,
                            sessionDisplaySub: $sessionDisplaySub,
                            userPresets: $userPresets
                        )
                        .environmentObject(fileController)
                        
                    }
                    Spacer()
                }
            }
        }
    }
}
