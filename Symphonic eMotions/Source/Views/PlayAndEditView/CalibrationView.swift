//  CalibrationView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2024.
//

import Combine
import SwiftUI

struct CalibrationView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var startViewModel: StartViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var isCalibrating: Bool = false
    @State private var calibrationThresholdCancellable: AnyCancellable?
    @State private var isCalibratingCancellable: AnyCancellable?
    @State private var calibrationThreshold: Int
    @State private var hasBeenUsed: Bool = false
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init(userSettings: UserSettings, setInfoModel: SetInfoModel) {
        _setInfoModel = ObservedObject(wrappedValue: setInfoModel)
        _calibrationThreshold = State(initialValue: userSettings.calibrationThreshold)
    }

    var body: some View {
        HStack {
            Button(action: {
                if isCalibrating {
                    setInfoModel.imageDifference.stopCalibration()
                } else {
                    setInfoModel.imageDifference.startCalibration()
                }
                hasBeenUsed = true
            }) {
                Text(isCalibrating ? "Niet bewegen!" : "Kalibreer Stilte")
                    .padding()
                    .background(
                        isCalibrating ? Color.red :
                            (hasBeenUsed ? Color.green : Color.orange) // Aangepast
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.trailing)
                    .padding(.bottom)
            }
            Text("\(calibrationThreshold)")
                .padding()
                .background(isCalibrating ? Color.red : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.trailing)
                .padding(.bottom)
        }
        .background(Color.clear)
        .onAppear {
            // Kalibratieveranderingen observeren en opslaan
            calibrationThresholdCancellable = setInfoModel.imageDifference.$calibrationThreshold
                .receive(on: RunLoop.main)
                .sink { newThreshold in
                    self.calibrationThreshold = newThreshold
                    // Sla de nieuwe waarde op in de @AppStorage variabele
                    userSettings.calibrationThreshold = newThreshold
                }
            isCalibratingCancellable = setInfoModel.imageDifference.$isCalibrating
                .receive(on: RunLoop.main)
                .sink { isCalibrating in
                    self.isCalibrating = isCalibrating
                }
        }
    }
}
