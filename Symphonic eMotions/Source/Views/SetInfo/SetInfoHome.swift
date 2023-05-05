//
//  SetInfoHome.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/02/2023.
//

import SwiftUI
import AVFoundation

enum Language: String, CaseIterable {
    case english = "en-US"
    case dutch = "nl-NL"
    
    var selectTaal: String {
        switch self {
        case .english:
            return "Select language"
        case .dutch:
            return "Selecteer taal"
        }
    }
    
    var taal: String {
        switch self {
        case .english:
            return "English"
        case .dutch:
            return "Nederlands"
        }
    }
    
    var helloWorld: String {
        switch self {
        case .english:
            return "Welcome in the Symphonic eMotions app. We will guide you to setup your iPad and speaker for the best experience possible"
        case .dutch:
            return "Welkom in de Symphonische emoties app. We zullen je begeleiden in het opzetten van de iPad en luidspreker voor de best mogelijke ervaring"
        }
    }
}

struct SetInfoHome: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    
    let synthesizer = AVSpeechSynthesizer()
    @State var selectedLanguage: Language = .english
    
    var body: some View {
        VStack{
            Spacer().frame(height:70)
            HStack {
                
                Image("LogoColor")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                
                
                Text("Symphonic eMotions Pro")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .padding(.leading, 40)
                
            }
            Spacer()
            
//            HStack {
//                Text(selectedLanguage.selectTaal)
//                Picker("Language", selection: $selectedLanguage) {
//                    ForEach(Language.allCases, id: \.self) { language in
//                        Text(language.taal)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .fixedSize()
//
//                Button(action: {
//                    let utterance = AVSpeechUtterance(string: selectedLanguage.helloWorld)
//                    utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage.rawValue)
//
//                    utterance.rate = 0.5
//                    utterance.pitchMultiplier = 1
//                    utterance.postUtteranceDelay = 0
//                    utterance.volume = 0.9
//
//                    synthesizer.speak(utterance)
//                }) {
//                    Text("Start")
//                        .padding()
//                        .background(Color.accentColor)
//                        .foregroundColor(Color.white)
//                        .cornerRadius(10.0)
//                }
//            }
//
//            Spacer()
        }
    }
}
