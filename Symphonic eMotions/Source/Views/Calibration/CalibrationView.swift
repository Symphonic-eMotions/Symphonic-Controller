//  CalibrationView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2024.
//

import Combine
import SwiftUI

struct CalibrationView: View {

    @ObservedObject var setInfoModel: SetInfoModel

    @State private var isCalibrating: Bool = false
    @State private var calibrationThreshold: Int = 0
    @State private var calibrationThresholdCancellable: AnyCancellable?
    @State private var isCalibratingCancellable: AnyCancellable?

    @State private var isCalibratingMax: Bool = false
    @State private var calibrationMaxThreshold: Int = 0
    @State private var calibrationMaxThresholdCancellable: AnyCancellable?
    @State private var isCalibratingMaxCancellable: AnyCancellable?

    private let minLimit = 0
    private let maxLimit = 255

    var body: some View {
        VStack(spacing: 16) {
            Text("Calibration")
                .font(.headline)

            // Twee compacte groepen naast elkaar
            HStack(spacing: 24) {
                // MIN
                CalibratorControl(
                    title: "Stilte  •  Min",
                    isActive: isCalibrating,
                    activeLabel: "Stilstaan!",
                    idleLabel: "Stilte",
                    start: { setInfoModel.imageDifference.startCalibration() },
                    stop:  { setInfoModel.imageDifference.stopCalibration() },
                    value: $calibrationThreshold,
                    decrement: {
                        let newValue = max(minLimit, calibrationThreshold - 1)
                        applyMin(newValue)
                    },
                    increment: {
                        // min mag niet boven max komen
                        let newValue = min(calibrationMaxThreshold, calibrationThreshold + 1)
                        applyMin(newValue)
                    }
                )

                // MAX
                CalibratorControl(
                    title: "Beweging  •  Max",
                    isActive: isCalibratingMax,
                    activeLabel: "Bewegeeg!",
                    idleLabel: "Beweging",
                    start: { setInfoModel.imageDifference.startCalibrationMax() },
                    stop:  { setInfoModel.imageDifference.stopCalibrationMax() },
                    value: $calibrationMaxThreshold,
                    decrement: {
                        // max mag niet onder min komen
                        let newValue = max(calibrationThreshold, calibrationMaxThreshold - 1)
                        applyMax(newValue)
                    },
                    increment: {
                        let newValue = min(maxLimit, calibrationMaxThreshold + 1)
                        applyMax(newValue)
                    }
                )
            }
            .padding(.horizontal, 20) // zijkant-padding voor het geheel
        }
        .onAppear {
            // Live updates vanuit ImageDifference
            calibrationThresholdCancellable = setInfoModel.imageDifference.calibrationThreshold
                .receive(on: RunLoop.main)
                .sink { newThreshold in
                    calibrationThreshold = newThreshold
                    setInfoModel.userSettings.calibrationMin = newThreshold
                }

            isCalibratingCancellable = setInfoModel.imageDifference.$isCalibrating
                .receive(on: RunLoop.main)
                .sink { isCalibrating = $0 }

            calibrationMaxThresholdCancellable = setInfoModel.imageDifference.calibrationMaxCeiling
                .receive(on: RunLoop.main)
                .sink { newThresholdMax in
                    calibrationMaxThreshold = newThresholdMax
                    setInfoModel.userSettings.calibrationMax = newThresholdMax
                }

            isCalibratingMaxCancellable = setInfoModel.imageDifference.$isCalibratingMax
                .receive(on: RunLoop.main)
                .sink { isCalibratingMax = $0 }
        }
    }

    // MARK: - Helpers (houden min ≤ max en syncen alles)
    private func applyMin(_ newValue: Int) {
        let clamped = max(minLimit, min(newValue, calibrationMaxThreshold))
        calibrationThreshold = clamped
        setInfoModel.userSettings.calibrationMin = clamped
        setInfoModel.imageDifference.setCalibrationThreshold(clamped)
    }

    private func applyMax(_ newValue: Int) {
        let clamped = max(calibrationThreshold, min(newValue, maxLimit))
        calibrationMaxThreshold = clamped
        setInfoModel.userSettings.calibrationMax = clamped
        setInfoModel.imageDifference.setCalibrationMaxCeiling(clamped)
    }
}
