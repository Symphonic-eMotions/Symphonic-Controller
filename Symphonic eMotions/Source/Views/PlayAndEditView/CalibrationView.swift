//  StartView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2024.
//

import SwiftUI
import Combine

struct CalibrationView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var startViewModel: StartViewModel
    @ObservedObject var setInfoModel: SetInfoModel
    @State private var isCalibrating: Bool = false
    @State private var calibrationThresholdCancellable: AnyCancellable?
    @State private var isCalibratingCancellable: AnyCancellable?
    @State private var calibrationThreshold: Int

    var geometry: GeometryProxy
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init(geometry: GeometryProxy, userSettings: UserSettings, setInfoModel: SetInfoModel) {
        self.geometry = geometry
        self._setInfoModel = ObservedObject(wrappedValue: setInfoModel)
        self._calibrationThreshold = State(initialValue: userSettings.calibrationThreshold)
    }

    var body: some View {
        ZStack {
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
            // Kalibratieveranderingen observeren en opslaan
            calibrationThresholdCancellable = setInfoModel.imageDifference.$calibrationThreshold
                .receive(on: RunLoop.main)
                .sink { newThreshold in
                    self.calibrationThreshold = newThreshold
                    // Sla de nieuwe waarde op in de @AppStorage variabele
                    userSettings.calibrationThreshold = newThreshold
                }
            isCalibratingCancellable = setInfoModel.imageDifference.$isCalibrating
                .receive(on: RunLoop.main)
                .sink { isCalibrating in
                    self.isCalibrating = isCalibrating
                }
        }
    }
}

//struct Triangle: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))  // Rechter middenpunt
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))  // Linker bovenpunt
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))  // Linker onderpunt
//        path.closeSubpath()
//        return path
//    }
//}
