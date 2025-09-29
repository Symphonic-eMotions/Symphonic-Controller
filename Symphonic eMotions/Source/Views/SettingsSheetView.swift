//
//  SettingsSheetView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 25/05/2023.
//

import SwiftUI

struct SettingsSheetView: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var showingSheet: Bool
    @State private(set) var localTempo: Int = 0

    var body: some View {
        let sensitivityBinding = Binding(
            get: { userSettings.sensitivityDeviation },
            set: {
                userSettings.sensitivityDeviation = $0
                setInfoModel.imageDifference.sensitivityDeviationSubject.send(Float($0))

                let sensitivityPlusDeviation = Float(userSettings.sensitivitySession + userSettings.sensitivityDeviation)
                setInfoModel.imageDifference.sensitivityToMaxValue(sensitivityPlusDeviation: sensitivityPlusDeviation)

                print("SENDING SESSION PRESET PLUS DEVIATION: \(userSettings.sensitivitySession) + \(userSettings.sensitivityDeviation)")
            }
        )

        let levelSpeedBinding = Binding(
            get: { setInfoModel.setSettings.levelSpeedSet },
            set: { setInfoModel.setSettings.levelSpeedSet = $0 }
        )

        let levelDifficulty = Binding(
            get: { setInfoModel.setSettings.levelDifficultySet },
            set: { setInfoModel.setSettings.levelDifficultySet = $0 }
        )

        return GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Spacer().frame(height: 50)

                    // Sensitivity deviation
                    VStack(alignment: .leading) {
                        Text("Sensitivity").padding(.top)
                        HStack {
                            Text("-")
                            Spacer()
                            Text("0")
                            Spacer()
                            Text("+")
                        }
                        Slider(value: sensitivityBinding, in: -0.25 ... 0.25)
                    }
                }

                FeedbackButtonsView(
                    setInfoModel: setInfoModel,
                    imageSide: UIScreen.main.bounds.width * 0.05,
                    userSettings: userSettings
                )

                // Level speed
                VStack(alignment: .leading) {
                    Text("Level speed \(String(format: "%.2f", levelSpeedBinding.wrappedValue))").padding(.top)
                    Slider(value: levelSpeedBinding, in: 0.01 ... 1)
                }

                HStack {
                    if userSettings.userCode == .creator {
                        VStack(alignment: .leading) {
                            Text("Level progress exponent \(String(format: "%.1f", userSettings.levelProgressExponent))").padding(.top)
                            Slider(value: userSettings.$levelProgressExponent, in: 0 ... 4)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Level difficulty \(String(format: "%.2f", levelDifficulty.wrappedValue))").padding(.top)
                        Slider(value: levelDifficulty, in: 0 ... 1)
                    }
                }

                HStack {
                    // Tempo
                    if setInfoModel.setSettings.hasTempo {
                        VStack(alignment: .leading) {
                            Text("Tempo").padding(.top)
                            HStack {
                                EMButton(action: {
                                    setInfoModel.tapSetTempoBPMMin()
                                    localTempo -= 1
                                }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                    Image(systemName: "minus")
                                }

                                EMButton(action: {
                                    print("Reset pressed")
                                    localTempo = 0
                                    setInfoModel.tapSetTempoReset()
                                }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                    Text(String(localTempo))
                                }

                                EMButton(action: {
                                    setInfoModel.tapSetTempoBPMPlus()
                                    localTempo += 1
                                }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    }
                    Spacer().frame(height: 50)
                }
                Spacer().frame(height: 50)

                HStack {
                    Spacer()

                    // Continue
                    EMButton(action: {
                        showingSheet = false
                    }, color: .green, isSolid: true) {
                        Text(NSLocalizedString("Continue", comment: ""))
                    }
                    .frame(width: geometry.size.width * 0.333)

                    // Start stop
                    EMButton(action: {
                        if userSettings.isSetPlaying {
                            setInfoModel.tapStopAudioEngine()
                            userSettings.isSetPlaying = false
                        } else {
                            setInfoModel.tapStartAudioEngine()
                            userSettings.isSetPlaying = true
                        }

                    }, color: .accentColor) {
                        Image(systemName: userSettings.isSetPlaying ? "stop.fill" : "play.fill")
                    }
                    .frame(width: geometry.size.width * 0.333)

                    Spacer()
                }
            }
            .padding()
        }
    }
}
