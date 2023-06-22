//
//  Introduction.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 21/06/2023.
//

import SwiftUI

class FrameExtractorViewModel: FrameExtractorDelegate, ObservableObject {
    @Published var image: CIImage? = nil
    let frameExtractor: FrameExtractor
    
    init() {
        self.frameExtractor = FrameExtractor.shared
        self.frameExtractor.delegate = self
    }
    
    func captured(image: CIImage) {
        DispatchQueue.main.async {
            self.image = image
        }
    }
    
    func calculateAvgWhiteValue(_ image: CIImage) -> Double {
        // Convert image to grayscale
        let grayImage = image.applyingFilter(CIFilter.colorMonochrome().name , parameters: [
            kCIInputImageKey: image,
            kCIInputIntensityKey: 1.0,
            "inputColor": CIColor(red: 0.5, green: 0.5, blue: 0.5)
        ])
        // Calculate average white value
        if let cgImage = CIContext().createCGImage(grayImage, from: grayImage.extent) {
            return self.calculateAvgWhiteValue(cgImage)
        }
        return 0.0
    }
    
    private func calculateAvgWhiteValue(_ image: CGImage) -> Double {
        let pixelData = image.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var sum: UInt64 = 0
        let height = image.height
        let width = image.width
        let bytesPerRow = image.bytesPerRow
        
        for y in 0 ..< height {
            let i = y * bytesPerRow
            for x in 0 ..< width {
                let index = i + x * 4
                let pixel: UInt32 = UInt32(data[index])
                sum += UInt64(pixel)
            }
        }
        let totalPixels = width * height
        let avgValue = Double(sum) / Double(totalPixels)
        return avgValue
    }
}

struct Introduction: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introduction"
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @ObservedObject var frameExtractorViewModel = FrameExtractorViewModel()
    
    @State var avgWhiteValue: Double = 0
    @State var whiteTestResult: String = "? %"
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
                                  NSLocalizedString("Audio is playing", comment: "") :
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
                            VolumeSlider()
                                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
                                .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                                .zIndex(101)
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
                        
                        //Test licht
                        ZStack {
                            Rectangle()
                                .frame(width: 220, height: 60)
                                .foregroundColor(.clear)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                .background( Color.accentColor )
                            
                            Text( NSLocalizedString("Text light", comment: ""))
                                .font(.system(size: 30))
                                .padding()
                        }
                        .onTapGesture {
                            //Do white average calculation here
                            self.avgWhiteValue = self.frameExtractorViewModel.calculateAvgWhiteValue(self.frameExtractorViewModel.image ?? CIImage())
                            whiteTestResult = "\(Int(avgWhiteValue/2.55))%"
                            
                            print("Connect to sensitivity")
                            
                        }
                        .padding()
                        
                        HStack {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 100, height: 100)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            ZStack{
                                Rectangle()
                                    .fill(Color(
                                        red: avgWhiteValue / 255.0,
                                        green: avgWhiteValue / 255.0,
                                        blue: avgWhiteValue / 255.0
                                    ))
                                    .frame(width: 100, height: 100)
                                    .border(Color.blue, width: 2)
                                    .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                Text(whiteTestResult)
                                    .font(.system(size: 30))
                            }
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                                .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        }
                        .padding()
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
                
                else if sessionDisplaySub == .page04 {
                    
                    IntroductionImage(
                        imageName: "page04",
                        customWidth: 1.0,
                        customHeight: 0.8
                    )
                    
                    Spacer()
                    
                    Text("Set feedback")
                    
                    Spacer()
                    
                    IntroductionTitle(
                        setInfoModel: setInfoModel,
                        sessionDisplay: $sessionDisplay,
                        sessionDisplaySub: $sessionDisplaySub,
                        localizedString: "Specift distance",
                        nextPage: .none,
                        introductionNoteNumbers: []
                    )
                    
                    Spacer()
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
                    
//                    Rectangle()
//                        .frame(width: 200, height: 60)
//                        .foregroundColor(.clear)
//                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
//                        .background( Color.accentColor )
//
//                    Text(NSLocalizedString("Back", comment: ""))
//                        .font(.system(size: 30))
//                        .padding()
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                .onTapGesture {
                    withAnimation {
                        let pages:[SessionDisplay:SessionDisplay] = [.page02:.page01,.page03:.page02,.page04:.page03]
                        if let prevPage = pages[sessionDisplaySub] {
                            sessionDisplaySub = prevPage
                        }
                    }
                }
            }
        }
    }
}

struct IntroductionImage: View {
    
    public var imageName: String
    public var customWidth: Double
    public var customHeight: Double
    
    var body: some View {
        let imageWidth = UIScreen.main.bounds.width * customWidth
        let imageHeight = UIScreen.main.bounds.height * customHeight
        
        HStack {
            Spacer()
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageWidth, height: imageHeight, alignment: .center)
            
            Spacer()
        }
        .padding(.top, 40)
    }
}

struct IntroductionTitle: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    public var localizedString: String
    public var nextPage: SessionDisplay
    var introductionNoteNumbers: [Int]
    
    var body: some View {
        
        HStack{
            
            Spacer()
            
            Text(NSLocalizedString(localizedString, comment: ""))
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
                    //Shit down audio test notes
                    if nextPage == .page03 {
                        setInfoModel.conductor.playNoteNumbersIntroduction(
                            trackId: "realLife",
                            soundSource: .audioBuffer,
                            noteNumbers: introductionNoteNumbers,
                            noteOn: true
                        )
                    }
                    
                    //At the end of the introduction go to the demo
                    if nextPage == .none {
                        sessionDisplay = .demo
                    }
                    else {
                        sessionDisplaySub = nextPage
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom)
    }
}
