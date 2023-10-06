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
    
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var sliderValue: Float = AVAudioSession.sharedInstance().outputVolume
    internal var testSoundNoteNumbers: [Int]
    
    var body: some View {

        VStack {
            
            HStack(spacing: 20) {
                
                //Volume down
                ZStack {
                    Rectangle()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        .background( Color.accentColor )
                    
                    Button(action: {
                        self.decreaseVolume()
                        
                        //Direct connection Introductie set
                        setInfoModel.conductor.playNoteNumbersIntroduction(
                            trackId: "Volume",
                            soundSource: .audioBuffer,
                            noteNumbers: testSoundNoteNumbers,
                            noteOn: false
                        )
                    }) {
                        Image(systemName: "speaker.minus.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                
                //Volume up
                ZStack {
                    Rectangle()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                        .background( Color.accentColor )
                    
                    Button(action: {
                        
                        self.increaseVolume()
                            
                        //Direct connection Introductie set
                        setInfoModel.conductor.playNoteNumbersIntroduction(
                            trackId: "Volume",
                            soundSource: .audioBuffer,
                            noteNumbers: testSoundNoteNumbers,
                            noteOn: false
                        )

                    }) {
                        Image(systemName: "speaker.plus.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                
                //Speaker visual
                SpeakerView(
                    sliderValue: $sliderValue
                )
                .padding(.leading, 90)
                .frame(width: 90, height: 90)
            }
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

