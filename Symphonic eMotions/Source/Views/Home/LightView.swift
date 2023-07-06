//
//  LightView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 21/06/2023.
//

import SwiftUI

struct LightView: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introduction"
    //Cannot save in Float
    @AppStorage(UserDefaultsKeys.videoFeedback) var videoFeedback: Double = 0.5
    @AppStorage(UserDefaultsKeys.sensitivitySession) var sensitivitySession: Double = 0.8
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    //Brightness analysis
    @ObservedObject var frameExtractorViewModel = FrameExtractorViewModel()
    @State private var whiteTimer: Timer? = nil
    @State var averageBrightness: Double = 0
    @State var averageBrightnessResult: String = ""
    @State var image: UIImage = UIImage()
    
    @State var showCameraPreview: Bool = false
    
    @State private var testSoundPlaying: Bool = false
    internal var testSoundNoteNumbers: [Int] = [36,38,40,41,43,57,59,48]
    
    @State var setIsPlaying: Bool = false;
    @State var isAbove30: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading){
            
            VStack(spacing: 0) {
                
                IntroductionImage(
                    imageName: "page03",
                    customWidth: 0.8,
                    customHeight: 0.6
                )
                
                Spacer()
                    
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
                            showCameraPreview.toggle()
                        }
                    }
                    
                    // Add this Image view for the preview
                    if showCameraPreview {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .padding()
                    }
                }
                .onAppear {
                    self.whiteTimer = Timer.scheduledTimer(
                        withTimeInterval: 0.25,
                        repeats: true
                    ) { timer in
                        
                        //The image to analyse
                        let ciImage = self.frameExtractorViewModel.image ?? CIImage()
                        
                        //Do white average calculation here
                        self.averageBrightness = self.frameExtractorViewModel.calculateAverageBrightness(
                            ciImage: ciImage
                        )
                        let averageBrightnessInt: Int = Int(averageBrightness/2.55)
                        isAbove30 = averageBrightnessInt >= 10
                        averageBrightnessResult = "\(averageBrightnessInt)%"
                        
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
                
                Spacer()
                
                HStack{
                    
                    Spacer()
                    
                    Text(NSLocalizedString("Enough light", comment: ""))
                        .font(.system(size: 40))
                        .padding()
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 200, height: 60)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background( !isAbove30 ? Color.gray : Color.accentColor )

                        Text(NSLocalizedString("Continue", comment: ""))
                            .font(.system(size: 30))
                            .padding()
                    }
                    .onTapGesture {
                        withAnimation {
                            
//                            sessionDisplay = .demo
//                            sessionDisplaySub = .none
                            
                            sessionDisplay = .home
                            sessionDisplaySub = .page04
                        }
                    }
                    .disabled(!isAbove30)
                    Spacer()
                }
                .padding(.bottom)
                
                Spacer()
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
