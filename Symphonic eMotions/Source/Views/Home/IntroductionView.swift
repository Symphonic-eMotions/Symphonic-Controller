//
//  IntroductionView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 21/06/2023.
//

import SwiftUI

struct IntroductionView: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introduction"

    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @State public var testSoundPlaying: Bool = false
    var testSoundNoteNumbers: [Int] = [36,38,40,41,43,57,59,48]
    
    @State var setIsPlaying: Bool = false;
    
    var body: some View {
        
        ZStack(alignment: .topLeading){
            
            VStack(spacing: 0) {
                
                //Standaard
                if sessionDisplaySub == .page01 {
                    
                    IntroductionImage(
                        imageName: "page01",
                        customWidth: 0.9,
                        customHeight: 0.7
                    )
                    
                    Spacer()
                    
                    Text(" ")
                        .padding()
                    
                    Spacer()
                    
                    IntroductionTitle(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub,
                        localizedString: "iPad in stand",
                        nextPage: .page02,
                        introductionNoteNumbers: []
                    )
                    
                    Spacer()
                }
                //Volume
                else if sessionDisplaySub == .page02 {
                    
                    IntroductionImage(
                        imageName: "page02",
                        customWidth: 0.8,
                        customHeight: 0.6
                    )
                    
                    Spacer()
                    
                    VStack{
                        
                        //Start stop on buttons itself
                        
//                        ZStack {
//                            Rectangle()
//                                .frame(width: 220, height: 60)
//                                .foregroundColor(.clear)
//                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
//                                .background( Color.accentColor )
//
//                            Text( testSoundPlaying ?
//                                  NSLocalizedString("Stop audio", comment: "") :
//                                    NSLocalizedString("Test audio", comment: "")
//                            )
//                            .font(.system(size: 30))
//                            .padding()
//                        }
//                        .onTapGesture {
//                            //Direct connection Introductie set
//                            setInfoModel.conductor.playNoteNumbersIntroduction(
//                                trackId: "realLife",
//                                soundSource: .audioBuffer,
//                                noteNumbers: testSoundNoteNumbers,
//                                noteOn: testSoundPlaying
//                            )
//
//                            testSoundPlaying.toggle()
//                        }
                        
                        //Volume
                        VStack(alignment: .leading){
                            
                            VolumeButtonsView(
                                setInfoModel: setInfoModel,
                                testSoundPlaying: $testSoundPlaying,
                                testSoundNoteNumbers: testSoundNoteNumbers
                            )
                            .padding(.top)
                                
                        }
                    }
                    Spacer()
                    
//                    IntroductionTitle(
//                        setInfoModel: setInfoModel,
//                        sessionDisplay: $sessionDisplay,
//                        sessionDisplaySub: $sessionDisplaySub,
//                        localizedString: "Connect audio",
//                        nextPage: .page03,
//                        introductionNoteNumbers: testSoundNoteNumbers
//                    )
//
                    HStack{
                        
                        Spacer()
                        
                        Text(NSLocalizedString("Connect audio", comment: ""))
                            .font(.system(size: 40))
                            .padding()
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 200, height: 60)
                                .foregroundColor(.clear)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                .background( testSoundPlaying ? Color.accentColor : .gray )
                                
                            Text(NSLocalizedString("Continue", comment: ""))
                                .font(.system(size: 30))
                                .padding()
                        }
                        .disabled( !testSoundPlaying )
                        .onTapGesture {
                            withAnimation {
                                //Shut down audio test notes
                                setInfoModel.conductor.playNoteNumbersIntroduction(
                                    trackId: "realLife",
                                    soundSource: .audioBuffer,
                                    noteNumbers: testSoundNoteNumbers,
                                    noteOn: true
                                )
                                
                                sessionDisplaySub = .page03
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom)
                    
                    Spacer()
                }
                
            }
            .onAppear{
                
                setInfoModel.tapStopAudioEngine()
                
                //Load set
                setInfoModel.tapSetRow(filePath: "Introductie.json")
                //Let @AppStorage know what is current
                currentUrl = "Introductie.json"
            }
            
            //Back button
            if sessionDisplaySub != .page01 {
                ZStack {
                    Image(systemName: "arrowshape.backward")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                .onTapGesture {
                    withAnimation {
                        //Paginering
                        let pages:[SessionDisplay:SessionDisplay] = [.page02:.page01,.page03:.page02,.page04:.page03]
                        if let prevPage = pages[sessionDisplaySub] {
                            sessionDisplaySub = prevPage
                        }
                    }
                }
            }
            ZStack {
                Image("LogoColor")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            }
            .padding(.top, UIScreen.main.bounds.height * 0.08)
            .padding(.leading, UIScreen.main.bounds.width * 0.85)
            .onTapGesture {
                withAnimation {
                    sessionDisplay = .demo
                    sessionDisplaySub = .demo
                }
            }
            .onLongPressGesture {
                withAnimation {
                    sessionDisplay = .pro
                    sessionDisplaySub = .pro
                }
            }
        }
    }
}
