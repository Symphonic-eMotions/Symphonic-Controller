//
//  PlayView.swift
//  PlayView
//
//  Created by Mihai Fratu on 29.07.2021.
//

import SwiftUI
import AudioKit

struct PlayView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var setInfoModel: SetInfoModel
    @EnvironmentObject var fileController: FileController
    @Binding public var sessionDisplay: SessionDisplay
    @StateObject private var columnOpacityController: ColumnOpacityController
    @StateObject private var cellOpacityController: CellOpacityController
    @StateObject private var gridModel: GridModel
    @State private var presentSettingSheet = false
    @State private var showMasterTrack: Bool = false
    @Binding public var showLevelPlayerFullScreen: Bool
    
    @State var currentTrackID: String
    @State var currentPartID: String
    @State var rampUp: Double
    @State var rampDown: Double
    @State var volume: Float
    
    @State private var initialRampUp: Double
    @State private var initialRampDown: Double
    
    @State private var selectedPattern: DevicePattern = .stap1 // Default value
    
    init(
        setInfoModel: SetInfoModel,
        sessionDisplay: Binding<SessionDisplay>,
        showLevelPlayerFullScreen: Binding<Bool>
    ){
        self.setInfoModel = setInfoModel
        self._columnOpacityController = StateObject(wrappedValue: ColumnOpacityController(count:(setInfoModel.setInfoState.currentInstrumentsSet.columns))
        )
        self._cellOpacityController = StateObject(wrappedValue: CellOpacityController(count:(setInfoModel.setInfoState.currentInstrumentsSet.rows * setInfoModel.setInfoState.currentInstrumentsSet.columns))
        )
        self._gridModel = StateObject(wrappedValue:
            GridModel(
                levelCount: setInfoModel.setSettings.levels.count,
                levelSubject: setInfoModel.leveling.currentSetLevelSubject,
                gridRows: setInfoModel.setInfoState.currentInstrumentsSet.rows,
                gridColumns: setInfoModel.setInfoState.currentInstrumentsSet.columns
            )
        )
        self._sessionDisplay = sessionDisplay
        self._showLevelPlayerFullScreen = showLevelPlayerFullScreen
        
        //Set the first track active in the editor
        self.currentTrackID = setInfoModel.setSettings.settingsCurrentTrackID
        setInfoModel.partFeedback.currentTrackID.value = setInfoModel.setSettings.settingsCurrentTrackID
        
        self.currentPartID = setInfoModel.setSettings.settingsCurrentPartID
        setInfoModel.partFeedback.currentPartID.value = setInfoModel.setSettings.settingsCurrentPartID
        
        self.rampUp = setInfoModel.setSettings.settingsRampUp
        self.rampDown = setInfoModel.setSettings.settingsRampDown
        self.volume = Float(RangeConverter.rangedToSlider(range: [-90,12], value: Double(setInfoModel.setSettings.settingsVolume)))
        
        _initialRampUp = State(initialValue: setInfoModel.setSettings.settingsRampUp)
        _initialRampDown = State(initialValue: setInfoModel.setSettings.settingsRampDown)
        
        if let initialPattern = DevicePattern(pattern: setInfoModel.userSettings.pattern) {
            self._selectedPattern = State(initialValue: initialPattern)
        }
    }
    
    var body: some View {
        
        VStack {
            
            #if targetEnvironment(macCatalyst)
            Rectangle().frame(height: 25).foregroundColor(Color.clear)
            #endif
            
//                if !showLevelPlayerFullScreen {
//                    LevelView(
//                        setInfoModel: setInfoModel
//                    )
                //Transport buttons
                PlayerControlsView(
                    setInfoModel: setInfoModel,
                    showMasterTrack: $showMasterTrack
                )
                .zIndex(100)
//                }
            
            //Video
            GeometryReader { geometry in
                ZStack{
                    VStack{
                        VideoPreviewViewRepresentable(
                            setInfoModel: setInfoModel
                        )
                        .aspectRatio(1.77777, contentMode: .fit)
                        .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                        .cornerRadius(10.0)
                        .opacity( setInfoModel.setInfoState.displayMode == .both ? 0.30 : 1.0)
                        
                        HStack {
                            VStack{
                                HStack{
                                    
                                    // Picker for Device Pattern
                                    Picker("Device Pattern", selection: $selectedPattern) {
                                        ForEach(DevicePattern.allCases, id: \.self) { pattern in
                                            Text(pattern.rawValue).tag(pattern)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle()) // Dropdown style
                                    .onChange(of: selectedPattern) { newValue in
                                        userSettings.pattern = newValue.rawValue
                                        
                                        // Stuur een OSC-bericht met waarde 0 naar elk patroon
                                        DevicePattern.allCases.forEach { pattern in
                                            OSCMessageSender.shared.sendOSCMessage(
                                                ipAddress: self.userSettings.ipAddress,
                                                port: self.userSettings.port,
                                                pattern: pattern.rawValue + "/direct", // Voeg de "/direct" toe
                                                value: 0.0 // Verzend 0 als de waarde
                                            )
                                        }
                                        
                                    }
                                    .padding()
                                    
                                    CalibrationView(
                                        geometry: geometry,
                                        userSettings: setInfoModel.userSettings,
                                        setInfoModel: setInfoModel
                                    )
                                    .zIndex(210)
                                }
                                //Display ramped value feedback
                                ValueFeedback(value: .init(
                                    get: {
                                        let currentBarLevel = Float(max(0, setInfoModel.partFeedbackState.ramped))
                                        return max(0, min(1, currentBarLevel))
                                    },
                                    set: {
                                        _ in
                                    }), title: "Ramped value" )
                                .frame(height: 28.0)
                                
                                RampSliderView(
                                    label: "Ramp up",
                                    value: Binding<Double>(
                                        get: { Double(userSettings.rampUp) },
                                        set: { newValue in
                                            userSettings.rampUp = Double(newValue)
                                        }
                                    ),
                                    showsLabel: true,
                                    isActive: true
                                )
                                .onChange(of: userSettings.rampUp) { newValue in
                                    setInfoModel.conductor.rampUp[currentPartID] = newValue
                                    setInfoModel.setSettings.tracks[currentTrackID]!.parts[currentPartID]!.rampUp = newValue
                                }
                                
                                RampSliderView(
                                    label: "Ramp down",
                                    value: Binding<Double>(
                                        get: { Double(userSettings.rampDown) },
                                        set: { newValue in
                                            userSettings.rampDown = Double(newValue)
                                        }
                                    ),
                                    showsLabel: true,
                                    isActive: true
                                )
                                .onChange(of: userSettings.rampDown) { newValue in
                                    setInfoModel.conductor.rampDown[currentPartID] = newValue
                                    setInfoModel.setSettings.tracks[currentTrackID]!.parts[currentPartID]!.rampDown = newValue
                                }
                            }
                            
                        }
                    }
                    .onAppear {
                        if UserDefaults.standard.object(forKey: UserDefaultsKeys.rampUp) == nil {
                            userSettings.rampUp = initialRampUp
                        }
                        if UserDefaults.standard.object(forKey: UserDefaultsKeys.rampDown) == nil {
                            userSettings.rampDown = initialRampDown
                        }
                    }
                    .sheet(isPresented: $presentSettingSheet) {
                        SettingsSheetView(
                            userSettings: userSettings,
                            setInfoModel: setInfoModel,
                            showingSheet: $presentSettingSheet
                        )
                    }
                }
            }
            .zIndex(110)
            
            
            
            
            
            
        }
        .padding(.horizontal)
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
                    
                    Slider(value: $value, in: minValue...maxValue)
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
