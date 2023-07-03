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
    
    //@State for slider status
    @State var masterEffectState: [[Float]] = []
    
    init(
        setInfoModel: SetInfoModel,
        masterEffect: State<[[Float]]>
    ){
        self.setInfoModel = setInfoModel
        self._masterEffectState = masterEffect
    }
    
    var body: some View {
        
        VStack{
            Spacer()
            ScrollView (.vertical){
                //Struct with effects, contains [struct] with parameters per effect
                let masterTrackStructure = setInfoModel.setInfoState.masterTrackStructure!
                ForEach( Array(masterTrackStructure.enumerated()), id: \.element ) { index, effect in
                    //Stack per effect
                    ZStack {
                        //Background color
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color(UIColor.darkGray))
                        
                        VStack(alignment: .leading) {
                            
                            Text(effect.effectName)
                                .font(.headline)
                                .padding(.vertical)
                            
                            ForEach( Array(effect.parameters!.enumerated()), id: \.element) { i, parameter in
                                
                                Text("\(parameter.name) \(parameter.range[0], specifier: parameter.range[1] >= 1000 ? "%.0f" : "%.2f") - \(parameter.range[1], specifier: "%.0f")")
                                
                                MasterSliderView(
                                    label: parameter.name,
                                    value: Binding(
                                        get: { self.masterEffectState[index][i] },
                                        set: { (newVal) in
                                            //Set @State for local binding
                                            self.masterEffectState[index][i] = newVal
                                            
//                                            let _ = print("newVal: \(newVal)")
                                            
                                            //Send to conductor for real time modification
                                            setInfoModel.conductor.forwardMasterTrackEffect(
                                                value: Double(newVal),
                                                nodeName: effect.effectName,
                                                parameter: parameter.name,
                                                parameterRange: parameter.range
                                            )
                                            
                                            
                                            //Store in object for writing to file (encoder)
                                            let rangedValue = setInfoModel.setSettings.masterEffects[index]!.parameters[i]!.range
                                            setInfoModel.setSettings.masterEffects[index]!.parameters[i]!.value = Double(
                                                RangeConverter.valueToRange(range: rangedValue, value: Double(newVal))
                                            )
                                        }
                                    ),
                                    range: parameter.range,
                                    showsLabel: false
                                ).onAppear {
                                    
                                    let rangedValue = setInfoModel.setSettings.masterEffects[index]!.parameters[i]!.value
                                    let rangedRange = setInfoModel.setSettings.masterEffects[index]!.parameters[i]!.range
                                    
                                    
                                    
                                    masterEffectState[index][i] = RangeConverter.rangedToSlider(range: rangedRange, value: rangedValue)
//
//                                    let _ = print("after: \(masterEffectState[index][i]) before: \(rangedRange) \(rangedValue)")
//
                                }
                            }
                            
                        }.padding()
                    }
                }
            }.padding()
            .frame(width: 800, height: 550)
        }
    }
}

struct MasterSliderView: View {
    
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
