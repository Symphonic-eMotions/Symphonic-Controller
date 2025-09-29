//
//  PlayView.swift
//  PlayView
//
//  Created by Mihai Fratu on 29.07.2021.
//

import AudioKit
import SwiftUI

struct PlayView: View {
    @ObservedObject var setInfoModel: SetInfoModel
    @EnvironmentObject var fileController: FileController
    @Binding var sessionDisplay: SessionDisplay
    @StateObject private var columnOpacityController: ColumnOpacityController
    @StateObject private var cellOpacityController: CellOpacityController
    @StateObject private var gridModel: GridModel
    @State private var presentSettingSheet = false
    @State private var showMasterTrack: Bool = false
    @Binding var showLevelPlayerFullScreen: Bool

    @State var currentTrackID: String
    @State var currentPartID: String

    @State private var selectedPattern: DevicePattern = .stap1
    @State private var rampUp: Double = 0.5
    @State private var rampDown: Double = 0.5
    @State private var initialRampUp: Double
    @State private var initialRampDown: Double

    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        showLevelPlayerFullScreen: Binding<Bool>
    ) {
        self.setInfoModel = setInfoModel
        _columnOpacityController = StateObject(wrappedValue: ColumnOpacityController(count: setInfoModel.setInfoState.currentInstrumentsSet.columns)
        )
        _cellOpacityController = StateObject(wrappedValue: CellOpacityController(count: setInfoModel.setInfoState.currentInstrumentsSet.rows * setInfoModel.setInfoState.currentInstrumentsSet.columns)
        )
        _gridModel = StateObject(wrappedValue:
            GridModel(
                levelCount: setInfoModel.setSettings.levels.count,
                levelSubject: setInfoModel.leveling.currentSetLevelSubject,
                gridRows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                gridColumns: setInfoModel.setInfoState.currentInstrumentsSet.columns
            )
        )
        _sessionDisplay = sessionDisplay
        _showLevelPlayerFullScreen = showLevelPlayerFullScreen

        // Set the first track active in the editor
        currentTrackID = setInfoModel.setSettings.settingsCurrentTrackID
        setInfoModel.partFeedback.currentTrackID.value = setInfoModel.setSettings.settingsCurrentTrackID

        currentPartID = setInfoModel.setSettings.settingsCurrentPartID
        setInfoModel.partFeedback.currentPartID.value = setInfoModel.setSettings.settingsCurrentPartID

        _initialRampUp = State(initialValue: setInfoModel.setSettings.settingsRampUp)
        _initialRampDown = State(initialValue: setInfoModel.setSettings.settingsRampDown)

        if let initialPattern = DevicePattern(pattern: setInfoModel.userSettings.pattern) {
            _selectedPattern = State(initialValue: initialPattern)
        } else {
            _selectedPattern = State(initialValue: .stap1)
        }

        // Initialize rampUp and rampDown using UserSettings, providing defaults
        let rampUpValue = setInfoModel.userSettings.getRampUp(
            for: _selectedPattern.wrappedValue,
            defaultValue: _initialRampUp.wrappedValue
        )
        _rampUp = State(initialValue: rampUpValue)

        let rampDownValue = setInfoModel.userSettings.getRampDown(
            for: _selectedPattern.wrappedValue,
            defaultValue: _initialRampDown.wrappedValue
        )
        _rampDown = State(initialValue: rampDownValue)
    }

    var body: some View {
        VStack {
            // Grid van knoppen
            GeometryReader { geometry in
                VStack {
                    // Safely calculate button dimensions
                    let totalSpacing: CGFloat = 40
                    let numberOfButtonsInRow: CGFloat = 3
                    let availableWidth = max(0, geometry.size.width - totalSpacing)
                    let buttonWidth = max(0, availableWidth / numberOfButtonsInRow)
                    let isPhone = UIDevice.current.userInterfaceIdiom == .phone

                    let buttonHeight: CGFloat = isPhone ? 75 : 100
                    let fontSize = min(max(12, buttonWidth * 0.2), 18) // Adjusted multiplier and max size

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                        spacing: 10
                    ) {
                        ForEach(DevicePattern.allCases, id: \.self) { pattern in
                            Button(action: {
                                selectedPattern = pattern
                                setInfoModel.userSettings.pattern = pattern.rawValue

                                // Update rampUp and rampDown for the new pattern, using defaults if necessary
                                rampUp = setInfoModel.userSettings.getRampUp(for: selectedPattern, defaultValue: initialRampUp)
                                rampDown = setInfoModel.userSettings.getRampDown(for: selectedPattern, defaultValue: initialRampDown)

                                // Update conductor and setSettings
                                setInfoModel.conductor.rampUp[currentPartID] = rampUp
                                setInfoModel.setSettings.tracks[currentTrackID]?.parts[currentPartID]?.rampUp = rampUp

                                setInfoModel.conductor.rampDown[currentPartID] = rampDown
                                setInfoModel.setSettings.tracks[currentTrackID]?.parts[currentPartID]?.rampDown = rampDown

                                // Stuur een OSC-bericht met waarde 0 naar elk patroon
                                for pattern in DevicePattern.allCases {
                                    OSCMessageSender.shared.sendOSCMessage(
                                        ipAddress: setInfoModel.userSettings.ipAddress,
                                        port: setInfoModel.userSettings.port,
                                        pattern: pattern.rawValue + "/direct",
                                        value: 0.0
                                    )
                                }
                            }) {
                                Text(pattern.displayName)
                                    .font(.system(size: fontSize))
                                    .frame(width: buttonWidth, height: buttonHeight)
                                    .background(
                                        selectedPattern == pattern ?
                                            (pattern == .stap0 ? Color.red : Color.blue)
                                            : Color.gray
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .frame(maxHeight: buttonHeight * 4 + 30)
                    .padding()
                    // Overige content (zoals CalibrationView en sliders en optionele camera)
                    VStack {
                        // Calibration en settings
                        HStack {
                            CalibrationView(
                                geometry: geometry,
                                userSettings: setInfoModel.userSettings,
                                setInfoModel: setInfoModel
                            )

                            // Settings button
                            SettingsButtonWithLongPress(
                                setInfoModel: setInfoModel
                            )
                            .padding(.top, -15)
                        }

                        // Visual feedback
                        ValueFeedback(value: .init(
                            get: {
                                let currentBarLevel = Float(max(0, setInfoModel.partFeedbackState.ramped))
                                return max(0, min(1, currentBarLevel))
                            },
                            set: {
                                _ in
                            }
                        ), title: "Beweging")
                            .frame(height: 28.0)
                        // Ramp up and Ramp down
                        HStack {
                            RampSliderView(
                                label: "Up",
                                value: $rampUp,
                                showsLabel: true,
                                isActive: true
                            )
                            .onChange(of: rampUp) { newValue in
                                // Save to UserSettings
                                setInfoModel.userSettings.setRampUp(newValue, for: selectedPattern)

                                // Update conductor and setSettings
                                setInfoModel.conductor.rampUp[currentPartID] = newValue
                                setInfoModel.setSettings.tracks[currentTrackID]?.parts[currentPartID]?.rampUp = newValue
                            }

                            RampSliderView(
                                label: "Down",
                                value: $rampDown,
                                showsLabel: true,
                                isActive: true
                            )
                            .onChange(of: rampDown) { newValue in
                                // Save to UserSettings
                                setInfoModel.userSettings.setRampDown(newValue, for: selectedPattern)

                                // Update conductor and setSettings
                                setInfoModel.conductor.rampDown[currentPartID] = newValue
                                setInfoModel.setSettings.tracks[currentTrackID]?.parts[currentPartID]?.rampDown = newValue
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Bepaal of de view in portretmodus is
                    let isPortrait = geometry.size.height > geometry.size.width

                    // Toon de VideoPreviewViewRepresentable alleen als de view in portretmodus is
                    if isPortrait {
                        VideoPreviewViewRepresentable(
                            setInfoModel: setInfoModel
                        )
                        .aspectRatio(1.77777, contentMode: .fit)
                        .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                        .cornerRadius(10.0)
                        .opacity(setInfoModel.setInfoState.displayMode == .both ? 0.30 : 1.0)
                        .padding()
                    }
                }
                .onAppear {
                    // Set rampUp and rampDown in conductor and setSettings
                    setInfoModel.conductor.rampUp[currentPartID] = rampUp
                    setInfoModel.setSettings.tracks[currentTrackID]?.parts[currentPartID]?.rampUp = rampUp

                    setInfoModel.conductor.rampDown[currentPartID] = rampDown
                    setInfoModel.setSettings.tracks[currentTrackID]?.parts[currentPartID]?.rampDown = rampDown
                }
                .sheet(isPresented: $presentSettingSheet) {
                    SettingsSheetView(
                        userSettings: setInfoModel.userSettings,
                        setInfoModel: setInfoModel,
                        showingSheet: $presentSettingSheet
                    )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SliderView: View {
    var label: LocalizedStringKey
    @Binding var value: Float
    var minValue: Float = 0
    var maxValue: Float = 1
    var showsSeparator: Bool
    var withPercentage: CGFloat = 0.7

    init(
        label: LocalizedStringKey,
        value: Binding<Float>,
        minValue: Float = 0,
        maxValue: Float = 1,
        showsSeparator: Bool = true,
        withPercentage: CGFloat = 0.7
    ) {
        self.label = label
        _value = value
        self.maxValue = minValue
        self.maxValue = maxValue
        self.showsSeparator = showsSeparator
        self.withPercentage = withPercentage
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(label)
                            .font(.headline)
                        Text("\(value)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    Spacer()

                    Slider(value: $value, in: minValue ... maxValue)
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * withPercentage)
                }
                .padding(.horizontal)

                if showsSeparator {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(height: 1.0)
                }
            }
        }
        .frame(height: 50.0)
    }
}
