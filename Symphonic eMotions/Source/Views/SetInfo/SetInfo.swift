//
//  SetInfo.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI

struct SetInfoLocalState {
    var setName: String
    var setConfig: String
    var sideBarHead: String
    
    init(sessioDisplay: SessionDisplay){
        self.setName = ""
        self.setConfig = ""
        self.sideBarHead = "Sets"
    }
}

struct SetInfo: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    @Binding public var urls: [URL]
    
    
    var body: some View {
        VStack{
            
            //.home is the page on entering app, also accesible by clicking the Sets header in the side bar
            if sessionDisplay == .home {
                SetInfoHome(
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay
                )
            }
            //Set info is also the navigator to saved files within the set
            else if sessionDisplay == .setInfo {
                
                //Here we got the Editor!
                if sessionDisplaySub == .setEditor {
                    
                    Text("Variation \(setInfoModel.setInfoLocalState.setName)")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                    
                    EditorView(
                        setInfoModel: setInfoModel,
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
                            
                            AppUtils.createSessionFile(
                                sensitivity: -1,
                                setURL: URL("dontOverWrite"))
                            
                            //Load the Set
//                            setInfoModel.tapSetRow(
//                                selectedCollection: setInfoModel.filterSet(
//                                    setName: setInfoModel.setInfoLocalState.setName
//                                )
//                            )
                            setInfoModel.tapSetRow(filePath: setInfoModel.setInfoLocalState.setName)
                            
                            
                            //Change the View
                            sessionDisplay = setInfoModel.setSettings.defaultSkin
                        }
                        Spacer()
                        EMButton(
                            action: {

                                setInfoModel.setInfoState.currentInstrumentsSet = AppUtils.loadInstrumentSet(json: setInfoModel.setInfoLocalState.setConfig)

                                let setSetting = AppUtils.setSettings(
                                    instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                                    sessionSettings: SessionSettings(sensitivity: -1, setURL: URL("newSetSetInfo"))
                                )

                                _ = AppUtils.createWorkingFile(
                                    setSettings: setSetting,
                                    instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
                                    duplicateLastTrack: false,
                                    asNewFile: true
                                )

                                urls = fileController.getContentsOfDirectory()
                                
                            }, color: .orange, isSolid: true, maxWidth: 150, height: 35
                        ){
                            Text("New variation")
                        }
                        .frame(width: 150, height: 50)
//                        .padding()
                        Spacer()
                    }
                    
                    Spacer(minLength: 20)
                    
                    Divider()

                    SavedSetsList(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub,
                        urls: $urls
                    )
                    .environmentObject(fileController)
                    
                    Spacer()
                }
            }
        }
    }
}
