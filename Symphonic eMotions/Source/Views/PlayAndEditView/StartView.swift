//  StartView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2024.
//

import SwiftUI
import Combine

struct StartView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var startViewModel: StartViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var isCalibrating: Bool = false
    @State private var calibrationThreshold: Int = 0
    @State private var calibrationThresholdCancellable: AnyCancellable?
    @State private var isCalibratingCancellable: AnyCancellable?
    
    var geometry: GeometryProxy
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Circle()
            .stroke(Color.primary, lineWidth: 20)
            .frame(width: geometry.size.height * 0.6, height: geometry.size.height * 0.6)
            .overlay(
                Button(action: {
//                    if !viewModel.isCountdownActive {
                        startViewModel.isLocalPlaying.toggle()
                    
                        if startViewModel.isLocalPlaying {
                            startViewModel.startCountdown()
                        }
//                    }
                }) {
                    
                    if startViewModel.isLocalPlaying {
                        Text("\(startViewModel.countdown)")
                            .font(.system(size: 100))
                            .foregroundColor(.primary)
                    } else {
                        Triangle()
                            .fill(Color.primary)
                            .frame(width: 60, height: 60)
                    }
                }
            )
            .background(Color.white.opacity(0.5))
            .clipShape(Circle())
            .onAppear {
                startViewModel.onCountdownComplete = {
                    setInfoModel.tapStartAudioEngine()
                    userSettings.isSetPlaying = true
                    startViewModel.initalizeModel()
                }
            }
            
            // Kalibratieknop
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if isCalibrating {
                            setInfoModel.imageDifference.stopCalibration()
                        } else {
                            setInfoModel.imageDifference.startCalibration()
                        }
                    }) {
                        Text(isCalibrating ? "Niet bewegen!" : "Kalibreer Stilte")
                        .padding()
                        .background(isCalibrating ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.trailing)
                        .padding(.bottom)
                    }
                    Text("\(calibrationThreshold)")
                    .padding()
                    .background(isCalibrating ? Color.red : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.trailing)
                    .padding(.bottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onAppear {
            calibrationThresholdCancellable = setInfoModel.imageDifference.$calibrationThreshold
                .receive(on: RunLoop.main)
                .sink { newThreshold in
                    self.calibrationThreshold = newThreshold
                }
            isCalibratingCancellable = setInfoModel.imageDifference.$isCalibrating
                .receive(on: RunLoop.main)
                .sink { isCalibrating in
                    self.isCalibrating = isCalibrating
                }

        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))  // Rechter middenpunt
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))  // Linker bovenpunt
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))  // Linker onderpunt
        path.closeSubpath()
        return path
    }
}
