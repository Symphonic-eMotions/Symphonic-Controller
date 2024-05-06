//
//  MasterVolumesView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 05/05/2024.
//

import SwiftUI

struct MasterVolumesView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State var volumes: [String:Float]
    
    init(
        setInfoModel: SetInfoModel
    ) {
        self.setInfoModel = setInfoModel
        var trackVolumesInit = [String: Float]()
        for track in setInfoModel.setSettings.tracks {
            let volume = track.value.instrumentVolume
            trackVolumesInit[track.value.trackId] = volume
        }
        _volumes = State(initialValue: trackVolumesInit)
    }
    
    var body: some View {
        
        Text("Track volumes")
        
        
        
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(UIColor.darkGray))

            VStack(alignment: .leading) {
                
                Text("Track volumes")
                    .font(.headline)
                    .padding(.vertical)
                
                ForEach(setInfoModel.setSettings.tracks.keys, id: \.self) { key in
                    
                    if let trackName = setInfoModel.setSettings.tracks[key]?.trackName{
                        
                        HStack {
                            Text("\(trackName)")
                            Spacer()
                        }
                        
                        MasterVolumeSliderView(
                            label: trackName,
                            value: Binding(
                                get: {
                                    let getVolume = self.volumes[key] ?? 0
                                    print("getting volume \(getVolume)")
                                    return getVolume
                                },
                                set: { newVal in
                                    
                                    print("setting newVal \(newVal)")
                                    
                                    self.volumes[key] = newVal
                                    
                                    setInfoModel.conductor.forwardInstrumment(
                                        value: Double(newVal),
                                        on: key,
                                        for: "amplitude"
                                    )
                                    
                                    setInfoModel.setSettings.tracks[key]?.instrumentVolume = newVal
                                }
                            ),
                            range: [-90,12],
                            showsLabel: false
                        )
                        .onAppear {
                            let storedVolume = setInfoModel.setSettings.tracks[key]?.instrumentVolume ?? 0
                            self.volumes[key] = storedVolume
                        }
                    }
                }
            }
            .padding()
        }
    }
}


struct MasterVolumeSliderView: View {
    
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
                    Slider(value: $value, in: -90...12)
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * 0.8)
                    
                    Text("\(value, specifier: range[1] >= 1000 ? "%.0f" : "%.2f")")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .frame(width: geometry.size.width * 0.2)
                }
            }
        }
        .frame(height: 40.0)
    }
}
