//
//  Introduction.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 21/06/2023.
//

import SwiftUI

struct Introduction: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    var body: some View {
    
        VStack(spacing: 0) {
            
            if sessionDisplaySub == .page01 {
                
                IntroductionImage(
                    imageName: "page01",
                    customWidth: 0.8,
                    customHeight: 0.6
                )
                
                Spacer()
                
                Text(" ")
                    .padding()
                
                Spacer()
                
                IntroductionTitle(
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    localizedString: "iPad in stand",
                    nextPage: .page02
                )
                
                Spacer()
            }
            
            else if sessionDisplaySub == .page02 {
                            
                IntroductionImage(
                    imageName: "page02",
                    customWidth: 0.8,
                    customHeight: 0.6
                )
                
                Spacer()
                
                //Start stop
                VStack(alignment: .leading){
                    HStack {
                        
                        EMButton(action: {
                            playViewModel.tapMediaControlButton()
                        }, color: .accentColor) {
                            Text(NSLocalizedString("Test audio", comment: ""))
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.333)
                        Spacer()
                    }
                }
                
                //Volume
                VStack(alignment: .leading){
                    Text("Volume").padding(.top)
                    VolumeSlider()
                        .frame(height: 10)
                        .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                        .zIndex(101)
                }
                
                Spacer()
                
                IntroductionTitle(
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    localizedString: "Connect audio",
                    nextPage: .page03
                )
                
                Spacer()
            }
            
            else if sessionDisplaySub == .page03 {
                
                IntroductionImage(
                    imageName: "page03",
                    customWidth: 0.8,
                    customHeight: 0.6
                )
                
                Spacer()
                
                Text("Set light")
                
                Spacer()
                
                IntroductionTitle(
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    localizedString: "Enough light",
                    nextPage: .page04
                )
                
                Spacer()
            }
            
            else if sessionDisplaySub == .page04 {
                
                
                IntroductionImage(
                    imageName: "page04",
                    customWidth: 0.8,
                    customHeight: 0.6
                )
                
                Spacer()
                
                Text("Set feedback")
                
                Spacer()
                
                IntroductionTitle(
                    sessionDisplay: $sessionDisplay,
                    sessionDisplaySub: $sessionDisplaySub,
                    localizedString: "Specift distance",
                    nextPage: .none
                )
                
                Spacer()
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
                .frame(width: imageWidth, height: imageHeight, alignment: .topLeading)
            
            Spacer()
        }
        .padding(.top, 40)
//        .border(.red)
    }
}
struct IntroductionTitle: View {
    
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    public var localizedString: String
    public var nextPage: SessionDisplay
    
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
                    
                    if nextPage == .none {
                        sessionDisplay = .demo
                    }
                    else{
                        sessionDisplaySub = nextPage
                    }
                }
            }
            
            Spacer()
        }
        .padding(.bottom)
    }
}
