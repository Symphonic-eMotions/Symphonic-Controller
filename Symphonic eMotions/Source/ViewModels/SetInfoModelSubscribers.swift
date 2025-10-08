//
//  SetInfoModelSubscribers.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 19/07/2023.
//

import Foundation

extension SetInfoModel {

    func subscribeToImageDifference() {
        cancellableImageDifference?.cancel()
        cancellableImageDifference = nil

        cancellableImageDifference = imageDifference.values.sink { [weak self] values in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.setInfoState.values = values

                let levelValue = self.conductor.valuesDidChange(
                    // These are the main values for controlling
                    values: values,
                    // Dynamic area's of interest
                    setSettings: self.setSettings,
                    // These 3 are for advanced view monitoring
                    currentSetLevel: self.leveling.currentSetLevelSubject.value,
                    partFeedbackTrackID: self.partFeedback.currentTrackID.value,
                    partFeedbackPartID: self.partFeedback.currentPartID.value
                )
            }
        }
    }

    func subscribeToPartFeedback() {
        cancellablePartFeddback?.cancel()
        cancellablePartFeddback = nil

        cancellablePartFeddback = conductor.forwardRampedPartFeedback.sink { [weak self] value in
            guard let self = self else { return }

            self.partFeedbackState.ramped = Double(value)

//            OSCMessageSender.shared.sendOSCMessage(
//                ipAddress: self.userSettings.ipAddress,
//                port: self.userSettings.port,
//                pattern: self.userSettings.pattern + "/direct",
//                value: Float(value)
//            )
        }
    }
}
