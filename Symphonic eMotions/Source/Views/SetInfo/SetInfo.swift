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
    
    var body: some View {
        VStack{
            
            if sessionDisplay == .home {
                SetInfoHome(
//                    sharedViewModel: sharedViewModel,
                    setInfoModel: setInfoModel,
                    sessionDisplay: $sessionDisplay
                )
            }
            else if sessionDisplay == .setInfo {
                
                Text("\(setInfoModel.setInfoLocalState.setName)")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                
                SetLoadAndPlay(setInfoModel: setInfoModel)
                    .onTapGesture {
                        
                        //Load the Set
                        setInfoModel.tapSetRow(selectedCollection: setInfoModel.filterSet(setName: setInfoModel.setInfoLocalState.setName))
                        
                        //Change the View
                        sessionDisplay = setInfoModel.setInfoLocalState.loadSessionDisplay
                    }
                
                SkinSelector(
//                    sharedViewModel: sharedViewModel,
                    setInfoModel: setInfoModel,
                    availableSkins: [SessionDisplay.swiftUI,SessionDisplay.spriteKit],
                    loadSessionDisplay: setInfoModel.setInfoLocalState.loadSessionDisplay
                )
                
                Spacer()
                
    //            Text("About this set. Saved versions:")
    //            Text("Calibrator")
    //            Spacer()
                
    //            SavedSettingsView(
    //                sideBarSetsViewModel: sideBarSetsViewModel,
    //                currenSetName: sideBarSetsViewModel.state.currentInstrumentsSetName,
    //                setCollection: setCollection
    //            ).environmentObject(fileController)
            }
            
            
            
        }
    }
}

struct SkinSelector: View {
    
//    @ObservedObject var sharedViewModel: SharedViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    var availableSkins: [SessionDisplay]
    @State var localSessionDisplay: SessionDisplay
    
    init(
//        sharedViewModel: SharedViewModel,
        setInfoModel: SetInfoModel,
        availableSkins: [SessionDisplay],
        loadSessionDisplay: SessionDisplay
    ){
//        self.sharedViewModel = sharedViewModel
        self.setInfoModel = setInfoModel
        self.availableSkins = availableSkins
        self.localSessionDisplay = loadSessionDisplay
    }
    
    var body: some View {
        
        HStack{
            Picker(
                "Skins",
                selection: Binding(
                    get: {
                        localSessionDisplay
                    },
                    set: { value in
                        localSessionDisplay = value
                        setInfoModel.setInfoLocalState.loadSessionDisplay = value
                    }
                )
                    
            ) {
                
                ForEach( availableSkins, id: \.self){
                    Text($0.title)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .fixedSize()
            .padding(.vertical, 10.0)
            .padding(.leading, 10.0)
            .foregroundColor(.white)
            .accentColor(Color.accentColor)
        }
    }
}

