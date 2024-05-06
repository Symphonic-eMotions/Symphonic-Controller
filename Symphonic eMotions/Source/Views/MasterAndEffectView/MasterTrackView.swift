//
//  MasterTrackView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 06/09/2022.
//

import SwiftUI
import OrderedCollections

struct MasterTrackView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding var showMasterTrack: Bool
    //@State for slider status
    @State var masterEffectState: [[Float]] = []
    
    init(
        setInfoModel: SetInfoModel,
        masterEffect: State<[[Float]]>,
        showMasterTrack: Binding<Bool>
    ){
        self.setInfoModel = setInfoModel
        self._masterEffectState = masterEffect
        self._showMasterTrack = showMasterTrack
    }
    
    var body: some View {
        
        return GeometryReader { geometry in
            
            VStack{
                masterTrackScrollView
                continueButton(geometry: geometry)
            }
        }
    }
    
    private var masterTrackScrollView: some View {
        
        ScrollView (.vertical){
            
            MasterVolumesView(setInfoModel: setInfoModel)
            
            //Struct with effects, contains [struct] with parameters per effect
            if let masterTrackStructure = setInfoModel.setInfoState.masterTrackStructure {
                
                ForEach( Array(masterTrackStructure.enumerated()), id: \.element ) { index, effect in
                    
                    EffectStackView(
                        effect: effect,
                        index: index,
                        masterEffectState: $masterEffectState,
                        setInfoModel: setInfoModel
                    )
                }
            }
        }
        .padding()
    }
    
    private func continueButton(geometry: GeometryProxy) -> some View {
        EMButton(action: {
            showMasterTrack = false
            
        }, color: .green, isSolid: true) {
            Text(NSLocalizedString("Continue", comment: ""))
        }
        .frame(width: geometry.size.width * 0.333)
    }
}

struct EffectStackView: View {
    var effect: MasterTrackEffect
    var index: Int
    @Binding var masterEffectState: [[Float]]
    var setInfoModel: SetInfoModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(UIColor.darkGray))

            VStack(alignment: .leading) {
                Text(effect.effectName)
                    .font(.headline)
                    .padding(.vertical)
                
                if let parameters = effect.parameters {
                    ForEach(Array(parameters.enumerated()), id: \.element) { i, parameter in
                        EffectParameterView(effect: effect, parameter: parameter, effectIndex: index, parameterIndex: i, masterEffectState: $masterEffectState, setInfoModel: setInfoModel)
                    }
                }
            }
            .padding()
        }
    }
}

struct EffectParameterView: View {
    var effect: MasterTrackEffect
    var parameter: Parameter
    var effectIndex: Int
    var parameterIndex: Int
    @Binding var masterEffectState: [[Float]]
    var setInfoModel: SetInfoModel

    var body: some View {
        HStack {
            Text("\(parameter.name)")
            Spacer()
            Text("\(parameter.range[0], specifier: parameter.range[1] >= 1000 ? "%.0f" : "%.2f") - \(parameter.range[1], specifier: "%.0f")")
        }

        MasterEffectSliderView(
            label: parameter.name,
            value: Binding(
                get: { self.masterEffectState[effectIndex][parameterIndex] },
                set: { newVal in
                    self.masterEffectState[effectIndex][parameterIndex] = newVal
                    setInfoModel.conductor.forwardMasterTrackEffect(
                        value: Double(newVal),
                        nodeName: effect.effectName,
                        parameter: parameter.name,
                        parameterRange: parameter.range
                    )
                    
                    let range = setInfoModel.setSettings.masterEffects[effectIndex]!.parameters[parameterIndex]!.range
                    setInfoModel.setSettings.masterEffects[effectIndex]!.parameters[parameterIndex]!.value = Double(
                        RangeConverter.valueToRange(range: range, value: Double(newVal))
                    )
                }
            ),
            range: parameter.range,
            showsLabel: false
        ).onAppear {
            let rangedValue = setInfoModel.setSettings.masterEffects[effectIndex]!.parameters[parameterIndex]!.value
            let rangedRange = setInfoModel.setSettings.masterEffects[effectIndex]!.parameters[parameterIndex]!.range
            
            masterEffectState[effectIndex][parameterIndex] = RangeConverter.rangedToSlider(
                range: rangedRange,
                value: rangedValue
            )
        }
    }
}

struct MasterEffectSliderView: View {
    
    var label: String
    @Binding var value: Float
    var range: [Double]
    var showsLabel: Bool
    
    init(label: String, value: Binding<Float>, range: [Double], showsLabel: Bool = true) {
        self.label = label
        _value = value
        self.range = range
        self.showsLabel = showsLabel
    }
    
    var body: some View {
        GeometryReader { geometry in
                
            ZStack{
                if showsLabel { Text(label) }
                HStack {
                    Slider(value: $value, in: 0...1)
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * 0.8)
                    
                    let valueInRange = RangeConverter.rangeToValue(range: range, value: Double(value))
//                    let valueInRange = value
                    
                    Text("\(valueInRange, specifier: range[1] >= 1000 ? "%.0f" : "%.2f")")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .frame(width: geometry.size.width * 0.2)
                }
            }
        }
        .frame(height: 40.0)
    }
}
