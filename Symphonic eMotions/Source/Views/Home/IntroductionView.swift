//
//  IntroductionView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 21/06/2023.
//

import SwiftUI

struct IntroductionView: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introduction"
    //Cannot save in Float
    @AppStorage(UserDefaultsKeys.videoFeedback) var videoFeedback: Double = 0.5
    @AppStorage(UserDefaultsKeys.sensitivity) var sensitivity: Double = 0.8


    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @ObservedObject var frameExtractorViewModel = FrameExtractorViewModel()
    
//    @State private var whiteTimer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    @State private var whiteTimer: Timer? = nil

    
    @State var averageBrightness: Double = 0
    @State var averageBrightnessResult: String = ""
    @State var image: UIImage = UIImage()
    @State var showPreview: Bool = false
    
    @State private var testSoundPlaying: Bool = false
    internal var testSoundNoteNumbers: [Int] = [36,38,40,41,43,57,59,48]
    
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
                        //Start stop
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 220, height: 60)
                                .foregroundColor(.clear)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                .background( Color.accentColor )
                            
                            Text( testSoundPlaying ?
                                  NSLocalizedString("Stop audio", comment: "") :
                                    NSLocalizedString("Test audio", comment: "")
                            )
                            .font(.system(size: 30))
                            .padding()
                        }
                        .onTapGesture {
                            //Direct connection Introductie set
                            setInfoModel.conductor.playNoteNumbersIntroduction(
                                trackId: "realLife",
                                soundSource: .audioBuffer,
                                noteNumbers: testSoundNoteNumbers,
                                noteOn: testSoundPlaying
                            )
                            
                            testSoundPlaying.toggle()
                        }
                        
                        //Volume
                        VStack(alignment: .leading){
                            
                            VolumeButtonsView()
                                .padding(.top)
                            
                        }
                    }
                    Spacer()
                    
                    IntroductionTitle(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub,
                        localizedString: "Connect audio",
                        nextPage: .page03,
                        introductionNoteNumbers: testSoundNoteNumbers
                    )
                    
                    Spacer()
                }
                //Licht
                else if sessionDisplaySub == .page03 {
                    
                    IntroductionImage(
                        imageName: "page03",
                        customWidth: 0.8,
                        customHeight: 0.6
                    )
                    
                    Spacer()
                    
                    HStack{
                        
                        HStack {
                            
                            ZStack{
                                Rectangle()
                                    .fill(Color(
                                        red: averageBrightness / 255.0,
                                        green: averageBrightness / 255.0,
                                        blue: averageBrightness / 255.0
                                    ))
                                    .frame(width: 100, height: 100)
                                    .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                Text(averageBrightnessResult)
                                    .font(.system(size: 30))
                            }
                            .padding()
                            .onTapGesture {
                                withAnimation{
                                    showPreview.toggle()
                                }
                            }
                            
                            // Add this Image view for the preview
                            if showPreview {
                                Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .padding()
                            }
                        }
                        .onAppear {
                            self.whiteTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                                //The image to analyse
                                let ciImage = self.frameExtractorViewModel.image ?? CIImage()

                                //Do white average calculation here
                                self.averageBrightness = self.frameExtractorViewModel.calculateAverageBrightness(
                                    ciImage: ciImage
                                )
                                averageBrightnessResult = "\(Int(averageBrightness/2.55))%"

                                // Convert CIImage to UIImage for preview
                                let context = CIContext(options: nil)
                                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                                    self.image = UIImage(cgImage: cgImage)
                                }
                                print("Connect or set ready for sensitivity")
                            }
                        }
                        .onDisappear {
                            self.whiteTimer?.invalidate()
                            self.whiteTimer = nil
                        }
                    }
                    
                    Spacer()
                    
                    IntroductionTitle(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub,
                        localizedString: "Enough light",
                        nextPage: .page04,
                        introductionNoteNumbers: []
                    )
                    
                    Spacer()
                }
                //Afstand
                else if sessionDisplaySub == .page04 {
                    
                    ZStack(alignment: .topLeading){
                        
                        VStack{
                            IntroductionImage(
                                imageName: "page04",
                                customWidth: 1.0,
                                customHeight: 0.8
                            )
                            
                            Spacer()
                            
                            IntroductionTitle(
                                setInfoModel: setInfoModel,
                                sessionDisplay: $sessionDisplay,
                                sessionDisplaySub: $sessionDisplaySub,
                                localizedString: "Specift distance",
                                nextPage: .page05,
                                introductionNoteNumbers: []
                            )
                            
                            Spacer()
                        }
                        
                        GeometryReader { geometry in
                            IntroductionSlider(
                                label: "Distance",
                                value: $videoFeedback,
                                minValue: 0,
                                maxValue: 1,
                                //This is the lenght of the slider
                                withPercentage: 0.55
                            )
                            //This is the roo from the top of the screen
                            .padding(.top, geometry.size.height * 0.6)
                            //And from the left
                            .padding(.leading, geometry.size.width * 0.1)
                        }
                    }
                }
                //Test
                else if sessionDisplaySub == .page05 {
                    
                    VStack{
                        
                        let imageWidth = UIScreen.main.bounds.width * 0.5
                        let imageHeight = UIScreen.main.bounds.height * 0.5
                        
                        Image("demoBlob")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imageWidth, height: imageHeight, alignment: .center)
                        
                        Spacer()
                        
                        HStack {
                            IntroductionSlider(
                                label: "Distance",
                                value: $videoFeedback,
                                minValue: 0,
                                maxValue: 1,
                                //This is the lenght of the slider
                                withPercentage: 0.8
                            )
                            IntroductionSlider(
                                label: "Sensitivity",
                                value: $sensitivity,
                                minValue: 0,
                                maxValue: 1,
                                //This is the lenght of the slider
                                withPercentage: 0.8
                            )
                        }
                        .padding(.bottom, 95)
                        .padding(.leading, 50)
                        
                        IntroductionTitle(
                            setInfoModel: setInfoModel,
                            sessionDisplay: $sessionDisplay,
                            sessionDisplaySub: $sessionDisplaySub,
                            localizedString: "Test set",
                            nextPage: .demo,
                            introductionNoteNumbers: []
                        )
                        .padding(.bottom)
                    }
                }
            }
            .onAppear{
                //Load introduction set
                if currentUrl != "Introductie.json" {
                    //Load set
                    setInfoModel.tapSetRow(filePath: "Introductie.json")
                    //Let @AppStorage know what is current
                    currentUrl = "Introductie.json"
                }
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
                        let pages:[SessionDisplay:SessionDisplay] = [.page02:.page01,.page03:.page02,.page04:.page03,.page05:.page04]
                        if let prevPage = pages[sessionDisplaySub] {
                            sessionDisplaySub = prevPage
                        }
                    }
                }
            }
        }
    }
}
