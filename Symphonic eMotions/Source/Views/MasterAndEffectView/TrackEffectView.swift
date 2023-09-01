//
//  TrackEffectView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/07/2023.
//

import SwiftUI
import OrderedCollections


struct TrackEffectView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var currentTrack: TrackSettings
    
    var trackId: String
    @State var trackEffectState: [[Float]]
    var trackEffectViewObject: [TrackEffect]
    
    @Binding var showTrackEffect: Bool

    init(
        setInfoModel: SetInfoModel,
        currentTrack: TrackSettings,
        trackId: String,
        showTrackEffect: Binding<Bool>
        
    ){
        self.setInfoModel = setInfoModel
        self.trackId = trackId
        self.currentTrack = currentTrack
        self._showTrackEffect = showTrackEffect
        self.trackEffectViewObject = TrackEffectsHelper.trackEffectViewObject(trackSettings: currentTrack)
        self.trackEffectState = TrackEffectsHelper.trackEffectsStateObject(viewObject: trackEffectViewObject)
    }
    
    var body: some View {
        
        return GeometryReader { geometry in
            
            VStack{
                ScrollView (.vertical){

                    ForEach( Array(trackEffectViewObject.enumerated()), id: \.element ) { index, effect in
                        
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
                                    
                                    HStack{
                                        Text("\(parameter.name)")
                                        Spacer()
                                        Text("\(parameter.range[0], specifier: parameter.range[1] >= 1000 ? "%.0f" : "%.2f") - \(parameter.range[1], specifier: "%.0f")")
                                    }
                                    
                                    EffectSliderView(
                                        value: Binding(
                                            get: { self.trackEffectState[index][i] },
                                            set: { newVal in
                                                //Set state for local binding
                                                self.trackEffectState[index][i] = newVal
                                                
                                                let dt = InstrumentsSet.Track.Part.DamperTarget(
                                                    trackId: currentTrack.trackId,
                                                    nodeType: .effect,
                                                    nodeName: effect.effectName,
                                                    parameter: parameter.name,
                                                    parameterRange: parameter.range,
                                                    parameterInversed: false,
                                                    midiData: nil,
                                                    nodeSettings: nil,
                                                    dampMode: nil
                                                )
                                                
                                                //Send to conductor for real time modification
                                                setInfoModel.conductor.forwardEffect(
                                                    value: Double(newVal),
                                                    for: dt
                                                )
                                                
                                                print("--> newVal \(newVal)")
                                                print(dt)
                                                
                                                //Store to disk in currentTrack
                                                
//                                                if let effect = currentTrack.effects[index],
//                                                   let parameter = effect.parameters[i] {
//
//                                                    let convertedValue = RangeConverter.valueToRange(
//                                                        range: parameter.range,
//                                                        value: Double(newVal)
//                                                    )
//                                                    //Store in object to disk
//                                                    parameter.value = Double(convertedValue)
//                                                }
                                            }
                                        ),
                                        range: parameter.range
                                    )
                                    .onAppear{
                                        
                                        let rangedValue = currentTrack.effects[index]!.parameters[i]!.value
                                        let rangedRange = currentTrack.effects[index]!.parameters[i]!.range
                                        
                                        trackEffectState[index][i] = RangeConverter.rangedToSlider(
                                            range: rangedRange,
                                            value: rangedValue
                                        )
                                    }
                                }
                            }.padding()
                        }
                    }
                }
                .padding()
                
                //Continue
                EMButton(action: {
                    showTrackEffect = false
                    
                }, color: .green, isSolid: true) {
                    Text(NSLocalizedString("Continue", comment: ""))
                }
                .frame(width: geometry.size.width * 0.333)
            }
        }
    }
}

struct EffectSliderView: View {
    
    @Binding var value: Float
    var range: [Double]
    
    init(value: Binding<Float>, range: [Double]) {
        _value = value
        self.range = range
    }
    
    var body: some View {
        GeometryReader { geometry in
                
            ZStack{
                HStack {
                    
                    let valueInRange = RangeConverter.rangeToValue(range: range, value: Double(value))
                    
                    Text("\(valueInRange, specifier: range[1] >= 1000 ? "%.0f" : "%.2f")")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .frame(width: geometry.size.width * 0.2)
                        
                    Slider(value: $value, in: 0...1)
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * 0.8)
                }
            }
        }
        .frame(height: 40.0)
    }
}
