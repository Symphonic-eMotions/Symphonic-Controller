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
    //What Skin WILL the set load
    var loadSessionDisplay: SessionDisplay
    
    init(sessioDisplay: SessionDisplay){
        self.setName = ""
        self.setConfig = ""
        self.sideBarHead = "Sets"
        self.loadSessionDisplay = sessioDisplay
    }
}

struct SetInfo: View {
    
//    @ObservedObject var sharedViewModel: SharedViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    
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
                
                Text("Set \(setInfoModel.setInfoLocalState.setName)")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                
                //Here we got the Editor!
                if sessionDisplaySub == .setEditor {
                    
                    EditorView(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub
                    ).environmentObject(fileController)
                }
                //Set Info
                else{
                    SetLoadAndPlay(setInfoModel: setInfoModel)
                        .onTapGesture {
                            
                            AppUtils.createSessionFile(
                                sensitivity: -1,
                                setURL: URL("dontOverWrite"))
                            
                            //Load the Set
                            setInfoModel.tapSetRow(
                                selectedCollection: setInfoModel.filterSet(
                                    setName: setInfoModel.setInfoLocalState.setName
                                )
                            )
                            
                            //Change the View
                            sessionDisplay = setInfoModel.setInfoLocalState.loadSessionDisplay
                        }
                    
                    SkinSelector(
                        setInfoModel: setInfoModel,
                        availableSkins: [SessionDisplay.swiftUI,SessionDisplay.spriteKit],
                        loadSessionDisplay: setInfoModel.setInfoLocalState.loadSessionDisplay
                    )
                    
                    Divider()

                    SavedSetsList(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub
                    )
                    .environmentObject(fileController)
                    
                    Divider()
                    Spacer()
                }
            }
        }
    }
}
