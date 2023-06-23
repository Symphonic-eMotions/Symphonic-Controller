//
//  VolumeButtonsView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/06/2023.
//

import SwiftUI
import MediaPlayer

struct VolumeView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView(frame: .zero)
        return volumeView
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        // Handle updates to the UIView
    }
}

struct VolumeButtonsView: View {
    
    @State private var sliderValue: Float = AVAudioSession.sharedInstance().outputVolume

    var body: some View {

//        GeometryReader { geometry in
            VStack {
                
                HStack(spacing: 20) {
                    
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background( Color.accentColor )
                        
                        Button(action: {
                            self.decreaseVolume()
                        }) {
                            Image(systemName: "speaker.minus.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                    }
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                            .background( Color.accentColor )
                        
                        Button(action: {
                            self.increaseVolume()
                        }) {
                            Image(systemName: "speaker.plus.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                    }
                
                    SpeakerView(
                        sliderValue: $sliderValue
                    )
                    .padding(.leading, 90)
                    .frame(width: 90, height: 90)
                    
                }
                    
//                SpeakerView(
//                    sliderValue: $sliderValue
//                )
//                .offset(
//                    x: UIScreen.main.bounds.width * 0.80,
//                    y: UIScreen.main.bounds.height * 0.35
//                )
            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .border(.red)
//        }
    }

    private func increaseVolume() {
        guard sliderValue < 1 else { return }
        sliderValue += 0.1
        changeSystemVolume(value: sliderValue)
    }

    private func decreaseVolume() {
        guard sliderValue > 0 else { return }
        sliderValue -= 0.1
        changeSystemVolume(value: sliderValue)
    }

    private func changeSystemVolume(value: Float) {
        let volumeView = MPVolumeView()
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                slider.value = value
            }
        }
    }
}

struct SpeakerView: View {
    @Binding var sliderValue: Float

    var body: some View {
        Group {
            if sliderValue < 0.01 {
                Image(systemName: "speaker.fill")
            } else if sliderValue < 0.333 {
                Image(systemName: "speaker.wave.1.fill")
            } else if sliderValue < 0.666 {
                Image(systemName: "speaker.wave.2.fill")
            } else {
                Image(systemName: "speaker.wave.3.fill")
            }
        }
        .font(.system(size: 50))
    }
}

