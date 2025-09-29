//
//  FeedbackButtonsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 06/07/2023.
//

import SwiftUI

struct FeedbackButtonsView: View {
    // @EnvironmentObject stops workinh here, zo replaced with @ObservedObject
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var selectedButton: Int?
    var imageSide: CGFloat

    init(
        setInfoModel: SetInfoModel,
        imageSide: CGFloat,
        userSettings: UserSettings
    ) {
        self.setInfoModel = setInfoModel
        self.imageSide = imageSide
        self.userSettings = userSettings

        _selectedButton = State(initialValue: self.setInfoModel.feedbackToButton(feedback: userSettings.videoFeedback))
    }

    var body: some View {
        HStack(spacing: 20) {
            ForEach(0 ..< 4) { buttonIndex in
                Button(action: {
                    self.selectedButton = buttonIndex
                    userSettings.videoFeedback = self.setInfoModel.buttonToFeedback(id: buttonIndex)
                    print("SENDING FEEDBACK PRESET: \(userSettings.videoFeedback)")
                    setInfoModel.imageDifference.feedback.send(Float(userSettings.videoFeedback))

                    userSettings.sensitivitySession = self.setInfoModel.buttonToSensitivity(id: buttonIndex)
                    let sensitivity = Float(userSettings.sensitivitySession + userSettings.sensitivityDeviation)
                    print("SENDING SESSION PRESET PLUS DEVIATION: \(userSettings.sensitivitySession) + \(userSettings.sensitivityDeviation)")
                    setInfoModel.imageDifference.sensitivityToMaxValue(sensitivityPlusDeviation: sensitivity)
                }) {
                    ZStack {
                        Rectangle()
                            .frame(width: imageSide, height: imageSide)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background(self.selectedButton == buttonIndex ? Color.accentColor : Color.gray)

                        Image("movementId\(buttonIndex)")
                            .resizable()
                            .frame(width: imageSide, height: imageSide)
                    }
                }
            }
        }
    }
}
