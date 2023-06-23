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

            HStack {
                Button(action: {
                    self.decreaseVolume()
                }) {
                    Image(systemName: "speaker.minus.fill")
                    .font(.system(size: 50))
                }

                Button(action: {
                    self.increaseVolume()
                }) {
                    Image(systemName: "speaker.plus.fill")
                    .font(.system(size: 50))
                }
                
                SpeakerView(
                    sliderValue: $sliderValue
                )
                .padding()
            }
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

