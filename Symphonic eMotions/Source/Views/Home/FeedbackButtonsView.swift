//
//  FeedbackButtonsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 06/07/2023.
//

import SwiftUI

struct FeedbackButtonsView: View {
    
    @AppStorage(UserDefaultsKeys.videoFeedback) var videoFeedback: Double = 0.5
    @AppStorage(UserDefaultsKeys.sensitivitySession) var sensitivitySession: Double = 0.5
    @AppStorage(UserDefaultsKeys.sensitivityDeviation) var sensitivityDeviation: Double = 0
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var selectedButton: Int? = nil
    var imageSide: CGFloat
    
    init(setInfoModel: SetInfoModel, imageSide: CGFloat){
        self.setInfoModel = setInfoModel
        self.imageSide = imageSide
        
        self._selectedButton = State(initialValue: self.setInfoModel.feedbackToButton(feedback: videoFeedback))
    }
    
    var body: some View {
        
        HStack(spacing: 20) {
            ForEach(0..<4) { buttonIndex in
                
                Button(action: {
                    
                    self.selectedButton = buttonIndex
                    
                    self.videoFeedback = self.setInfoModel.buttonToFeedback(id: buttonIndex)
                    print("SENDING FEEDBACK PRESET: \(self.videoFeedback)")
                    setInfoModel.imageDifference.feedback.send(Float(self.videoFeedback))
                    
                    self.sensitivitySession = self.setInfoModel.buttonToSensitivity(id: buttonIndex)
                    let sensitivity: Float = Float(sensitivitySession + sensitivityDeviation)
                    print("SENDING SESSION PRESET PLUS DEVIATION: \(self.sensitivitySession) + \(self.sensitivityDeviation)")
                    setInfoModel.imageDifference.sensitivityToMaxValue(sensitivityPlusDeviation: sensitivity)

                    
                }) {
                    ZStack{
                        Rectangle()
                            .frame(width: imageSide, height: imageSide)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background( self.selectedButton == buttonIndex ? Color.accentColor : Color.gray)

                        Image("movementId\(buttonIndex)")
                            .resizable()
                            .frame(width: imageSide, height: imageSide)
                    }
                }
            }
        }
    }
}
