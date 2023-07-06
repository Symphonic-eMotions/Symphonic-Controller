//
//  FeedbackButtonsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 06/07/2023.
//

import SwiftUI

struct FeedbackButtonsView: View {
    
    @AppStorage(UserDefaultsKeys.videoFeedback) var videoFeedback: Double = 0.5
    
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
            ForEach(0..<4) { column in
                
                Button(action: {
                    self.selectedButton = column
                    self.videoFeedback = self.setInfoModel.buttonToFeedback(id: column)
                    print("SENDING FEEDBACK: \(self.videoFeedback)")
                    setInfoModel.imageDifference.feedback.send(Float(self.videoFeedback))
                }) {
                    ZStack{
                        Rectangle()
                            .frame(width: imageSide, height: imageSide)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background( self.selectedButton == column ? Color.accentColor : Color.gray)

                        Image("movementId\(column)")
                            .resizable()
                            .frame(width: imageSide, height: imageSide)
                    }
                }
            }
        }
    }
}
