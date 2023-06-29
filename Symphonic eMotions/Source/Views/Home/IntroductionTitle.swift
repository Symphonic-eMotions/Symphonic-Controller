//
//  IntroductionTitle.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/06/2023.
//

import SwiftUI

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
                    //Shut down audio test notes
                    if nextPage == .page03 {
                        setInfoModel.conductor.playNoteNumbersIntroduction(
                            trackId: "realLife",
                            soundSource: .audioBuffer,
                            noteNumbers: introductionNoteNumbers,
                            noteOn: true
                        )
                    }
                    //At the end of the introduction go to the demo
                    if nextPage == .demo {
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
