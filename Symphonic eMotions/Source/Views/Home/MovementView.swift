//
//  MovementView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 26/06/2023.
//

import SwiftUI

struct MovementView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @State private var selectedButton: Int? = nil
    //We may continue anyways
    @State var hasTested: Bool = true
    
    @State private var rotationSpeed: Double = 0
    
    @State private var presentSettingSheet = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading){
            
            VStack(spacing: 0) {
                
                //Visual Feedback
                VStack {
                    WarpHoleView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        print("short")
                        presentSettingSheet = true
                    }
                    .onLongPressGesture(minimumDuration: 1) {
                        print("long")
                        presentSettingSheet = true
                    }
                    .sheet(isPresented: $presentSettingSheet) {
                        SettingsSheetView(
                            setInfoModel: setInfoModel,
                            showingSheet: $presentSettingSheet
                        )
                        .background(Color.black.opacity(0.5))
                    }
                }
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                
                Spacer()
                VStack{
                    
                    FeedbackButtonsView(
                        setInfoModel: setInfoModel,
                        imageSide:  UIScreen.main.bounds.width * 0.12
                    )
                    
                    //Play and continue
                    HStack {
                        
                        //Play / stop Introductie set
                        ZStack {
                            Rectangle()
                                .frame(width: 200, height: 60)
                                .foregroundColor(.clear)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                .background( Color.accentColor )
                            
                            //Button text
                            if userSettings.isSetPlaying {
                                Text(NSLocalizedString("Stop set", comment: ""))
                                    .font(.system(size: 30))
                                    .padding()
                            }
                            else{
                                Text(NSLocalizedString("Test set", comment: ""))
                                    .font(.system(size: 30))
                                    .padding()
                            }
                        }
                        .onTapGesture {
                            
                            //Make continue available
                            hasTested = true
                            
                            //Turn testing off
                            if userSettings.isSetPlaying {
                                userSettings.isSetPlaying = false
                                rotationSpeedSubject.send(0)
                                setInfoModel.tapStopAudioEngine()
                            }
                            //Turn testing on
                            else{
                                setInfoModel.tapStartAudioEngine()
                                userSettings.isSetPlaying = true
                            }
                        }
                        
                        //Title
                        Text(NSLocalizedString("Movement amount", comment: ""))
                            .font(.system(size: 40))
                            .padding()
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 200, height: 60)
                                .foregroundColor(.clear)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                .background( Color.accentColor )
                            
                            Text(NSLocalizedString("Continue", comment: ""))
                                .font(.system(size: 30))
                                .padding()
                        }
                        .onTapGesture {
                            withAnimation {
                                
                                setInfoModel.tapStopAudioEngine()
                                
                                userSettings.isSetPlaying = false
                                
                                sessionDisplay = .demo
                                sessionDisplaySub = .demo
                            }
                        }
                        .disabled(!hasTested)
                    }
                }
            }
            .onAppear{
                
                print("MovementView page: \(sessionDisplay) / \(sessionDisplaySub)")
                
                setInfoModel.tapStopAudioEngine()
                
                //Load set
                setInfoModel.tapSetRow(filePath: "Introductie.json")
                
                //Store current location
                userSettings.currentUrl = "Introductie.json"
            }
            
            //Back button
            ZStack {
                Image(systemName: "arrowshape.backward")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .onTapGesture {
                withAnimation {
                    
                    setInfoModel.tapStopAudioEngine()
                    
                    userSettings.isSetPlaying = false
                    
                    //Paginering
                    let pages:[SessionDisplay:SessionDisplay] = [.page02:.page01,.page03:.page02,.page04:.page03]
                    if let prevPage = pages[sessionDisplaySub] {
                        sessionDisplaySub = prevPage
                    }
                }
            }
            
        }
        .onAppear{
            AnalyticsAction.trySet.logEvent(sessionDisplay: sessionDisplay)
        }
    }
}

