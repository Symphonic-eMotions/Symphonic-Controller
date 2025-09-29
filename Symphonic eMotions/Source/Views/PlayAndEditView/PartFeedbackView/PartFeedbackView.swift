//
//  PartFeedbackView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 28/05/2022.
//

import SwiftUI

//
// struct PartFeedbackView: View {
//
//    @EnvironmentObject var userSettings: UserSettings
//    @ObservedObject var setInfoModel: SetInfoModel
//    @EnvironmentObject var fileController: FileController
//    @Binding public var sessionDisplay: SessionDisplay
//
//    @State var currentTrackID: String
//    @State var currentPartID: String
//    @State var rampUp: Float
//    @State var rampDown: Float
//    @State var volume: Float
//
//    var setSettings: SetSettings
//
//    init(
//        setInfoModel: SetInfoModel,
//        sessionDisplay: Binding<SessionDisplay>
//    ){
//
//        self.setInfoModel = setInfoModel
//
//        self._sessionDisplay = sessionDisplay
//
//        //Set Settings for building interface
//        self.setSettings = setInfoModel.setSettings
//
//        //Set the first track active in the editor
//        self.currentTrackID = setSettings.settingsCurrentTrackID
//        setInfoModel.partFeedback.currentTrackID.value = setSettings.settingsCurrentTrackID
//
//        self.currentPartID = setSettings.settingsCurrentPartID
//        setInfoModel.partFeedback.currentPartID.value = setSettings.settingsCurrentPartID
//
//        self.rampUp = Float(setSettings.settingsRampUp)
//        self.rampDown = Float(setSettings.settingsRampDown)
//        self.volume = Float(RangeConverter.rangedToSlider(range: [-90,12], value: Double(setSettings.settingsVolume)))
//    }
//
//    var body: some View {
//
//        VStack {
//
//            //Select Track and select Part Pickers
//            VStack {
//                Picker(
//                    "Tracks",
//                    selection: Binding(get: {
//                        currentTrackID
//
//                    }, set: { value in
//
//                        currentTrackID = value
//                        setInfoModel.partFeedback.currentTrackID.send(value)
//
//                        setInfoModel.setSettings.settingsCurrentTrackID = currentTrackID
//
//                        let settingsVolume = setSettings.tracks[value]!.instrumentVolume
//
//                        volume = Float(RangeConverter.rangedToSlider(range: [-90,12], value: Double(settingsVolume)))
//                        setInfoModel.setSettings.settingsVolume = settingsVolume
//
//                        currentPartID = setSettings.tracks[currentTrackID]!.parts.keys.first!
//                        setInfoModel.partFeedback.currentPartID.send(currentPartID)
//                        setInfoModel.setSettings.settingsCurrentPartID = currentPartID
//
//                        let settingRampUp  = setSettings.tracks[currentTrackID]!.parts[currentPartID]!.rampUp
//                        rampUp = Float(settingRampUp)
//                        setInfoModel.setSettings.settingsRampUp = settingRampUp
//
//                        let settingsRampDown = setSettings.tracks[currentTrackID]!.parts[currentPartID]!.rampDown
//                        rampDown = Float(settingsRampDown)
//                        setInfoModel.setSettings.settingsRampDown = settingsRampDown
//
//                        setInfoModel.setInfoState.updateEditView += 1
//                    }),
//                    content: {
//                        ForEach(setSettings.tracks.keys, id: \.self) { key in
//                            Text(setSettings.tracks[key]!.trackName).tag(key)
//                        }
//                    }
//                )
//                .pickerStyle(SegmentedPickerStyle())
//                .foregroundColor(.red)
//                .accentColor(.blue)
//
//                //Select part of track
//                HStack {
//                    Picker(
//                        "Parts",
//                        selection: Binding(get: {
//                            currentPartID
//
//                        }, set: { value in
//
//                            currentPartID = value
//                            setInfoModel.partFeedback.currentPartID.send(value)
//                            setInfoModel.setSettings.settingsCurrentPartID = currentPartID
//
//                            let settingRampUp  = setSettings.tracks[currentTrackID]!.parts[value]!.rampUp
//                            rampUp = Float(settingRampUp)
//                            setInfoModel.setSettings.settingsRampUp = settingRampUp
//
//                            let settingsRampDown = setSettings.tracks[currentTrackID]!.parts[value]!.rampDown
//                            rampDown = Float(settingsRampDown)
//                            setInfoModel.setSettings.settingsRampDown = settingsRampDown
//
//                            setInfoModel.setInfoState.updateEditView += 1
//                        }),
//                        content: {
//                            let track = setSettings.tracks[currentTrackID] ?? nil
//                            if track != nil {
//                                let parts = track!.parts
//                                ForEach( parts.keys, id: \.self ) { key in
//                                    Text( parts[key]!.partName).tag(parts[key]!.id)
//                                }
//                            }
//                        }
//                    )
//                    .pickerStyle(SegmentedPickerStyle())
//                    .foregroundColor(.red)
//                    .accentColor(.blue)
//                }
//            }
//            //Visual feedback Ramped value
//            //Volume slider
//            //Ramp sliders
//            //ColorPickerTack
//            //Write button
//            VStack( alignment: .trailing ) {
//
//                HStack {
//
//                    VStack{
//                        //Display ramped value feedback
//                        ValueFeedback(value: .init(
//                            get: {
//                                let currentBarLevel = Float(max(0, setInfoModel.partFeedbackState.ramped))
//                                return max(0, min(1, currentBarLevel))
//                            },
//                            set: {
//                                _ in
//                            }), title: "Ramped value" )
//                        .frame(height: 28.0)
//                    }
//
//                    VStack{
//
//                        RampSliderView(
//                            label: "Ramp up",
//                            value: Binding(
//                                get: { self.rampUp },
//                                set: { (newVal) in
//                                    self.rampUp = newVal
//
//                                    setInfoModel.conductor.rampUp[currentPartID] = Double(newVal)
//                                    setSettings.tracks[currentTrackID]!.parts[currentPartID]!.rampUp = Double(newVal)
//                                }
//                            ),
//                            showsLabel: true,
//                            isActive: (currentPartID != "")
//                        )
//
//                        RampSliderView(
//                            label: "Ramp down",
//                            value: Binding(
//                                get: { self.rampDown },
//                                set: { (newVal) in
//                                    self.rampDown = newVal
//
//                                    setInfoModel.conductor.rampDown[currentPartID] = Double(newVal)
//                                    setSettings.tracks[currentTrackID]!.parts[currentPartID]!.rampDown = Double(newVal)
//                                }
//                            ),
//                            showsLabel: true,
//                            isActive: (currentPartID != "")
//                        )
//                    }
//                }
//
//                if currentTrackID != "" {
//
//                    HStack {
//                        InsrtumentColorPicker(
//                            setInfoModel: setInfoModel
//                        )
//
//                        //New set, not in playlist
//                        EMButton(
//                            action: {
//
//                                let fileName = AppUtils.createWorkingFile(
//                                    setSettings: setSettings,
//                                    instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
//                                    duplicateLastTrack: false,
//                                    asNewFile: true
//                                )
//
//                                fileController.addSetFileURLToController(fileName: fileName)
//
//                                sessionDisplay = .setInfo
//                            }, color: .orange, isSolid: true, maxWidth: 130, height: 35
//                        ){
//                            Text("New Set")
//                        }.frame(width: 130)
//
//                        //Save set, if not a bundle file
//                        if userSettings.currentUrl.contains("/Documents/") {
//
//                            //Save user file / playlist file
//                            EMButton(
//                                action: {
//
//                                    let fileName = AppUtils.createWorkingFile(
//                                        setSettings: setSettings,
//                                        instrumentSet: setInfoModel.setInfoState.currentInstrumentsSet,
//                                        duplicateLastTrack: false,
//                                        asNewFile: false
//                                    )
//                                    fileController.addSetFileURLToController(fileName: fileName)
//
//                                    userSettings.showPartEditor = false
//
//                                }, color: .red, isSolid: true, maxWidth: 130, height: 35
//                            ){
//                                Text("Save")
//                            }
//                            .frame(width: 130)
//                        }
//                    }
//                }
//            }
//        }
//        .onDisappear {
//            // This will be called when the view is no longer visible
//            userSettings.showPartEditor = false
//        }
//    }
// }
//
//// Graphical display value in slider
struct ValueFeedback: View {
    @Binding var value: Float
    var title: String

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.secondary)

                Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.primary)

                Text(title).foregroundColor(.accentColor).padding(.leading)
            }.cornerRadius(45.0)
        }
    }
}

struct RampSliderView: View {
    var label: String
    @Binding var value: Double
    var minValue: Float = 0
    var maxValue: Float = 1
    var displayRange: [Double]
    var specifier: String
    var showsLabel: Bool
    var isActive: Bool

    init(
        label: String,
        value: Binding<Double>,
        minValue: Float = 0,
        maxValue: Float = 1,
        displayRange: [Double] = [0, 1],
        specifier: String = "%.4f",
        showsLabel: Bool = true,
        isActive: Bool = true
    ) {
        self.label = label
        _value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.displayRange = displayRange
        self.specifier = specifier
        self.showsLabel = showsLabel
        self.isActive = isActive
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                if showsLabel { Text(label) }
                Slider(value: $value, in: Double(minValue) ... Double(maxValue))
                    .foregroundColor(.accentColor)
                    .frame(width: geometry.size.width * 0.8)

                // Transform linear value to exponential
                let expValue = pow(value, 3)
                let displayValue = Float(RangeConverter.valueToRange(range: displayRange, value: Double(expValue)))
//                    Text("\(displayValue, specifier: "\(specifier)")")
//                        .foregroundColor(.white)
//                        .font(.subheadline)
//                        .frame(width: geometry.size.width * 0.2)
            }
        }
        .frame(height: 40.0)
    }
}
