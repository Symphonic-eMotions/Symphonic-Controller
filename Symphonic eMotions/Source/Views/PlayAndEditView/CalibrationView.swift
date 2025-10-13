//  CalibrationView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 18/04/2024.
//

import Combine
import SwiftUI

struct CalibrationView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    @State private var isCalibrating: Bool = false
    @State private var calibrationThreshold: Int = 0
    @State private var calibrationThresholdCancellable: AnyCancellable?
    @State private var isCalibratingCancellable: AnyCancellable?
    
    @State private var isCalibratingMax: Bool = false
    @State private var calibrationMaxThreshold: Int = 0
    @State private var calibrationMaxThresholdCancellable: AnyCancellable?
    @State private var isCalibratingMaxCancellable: AnyCancellable?
    
    var body: some View {
        
        VStack{
            Text("Calibration")
            HStack {
                // Minimum
                HStack{
                    Button(action: {
                        if isCalibrating {
                            setInfoModel.imageDifference.stopCalibration()
                        } else {
                            setInfoModel.imageDifference.startCalibration()
                        }
                    }) {
                        Text(isCalibrating ? "Stilstaan!" : "Stilte")
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
                .onAppear {
                    calibrationThresholdCancellable = setInfoModel.imageDifference.calibrationThreshold
                        .receive(on: RunLoop.main)
                        .sink { newThreshold in
                            self.calibrationThreshold = newThreshold
                            setInfoModel.userSettings.calibrationMin = newThreshold
                        }
                    isCalibratingCancellable = setInfoModel.imageDifference.$isCalibrating
                        .receive(on: RunLoop.main)
                        .sink { isCalibrating in
                            self.isCalibrating = isCalibrating
                        }
                }
                
                // Maximum
                HStack{
                    Button(action: {
                        if isCalibratingMax {
                            setInfoModel.imageDifference.stopCalibrationMax()
                        } else {
                            setInfoModel.imageDifference.startCalibrationMax()
                        }
                    }) {
                        Text(isCalibratingMax ? "Bewegeeg!" : "Beweging")
                            .padding()
                            .background(isCalibratingMax ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.trailing)
                            .padding(.bottom)
                    }
                    Text("\(calibrationMaxThreshold)")
                        .padding()
                        .background(isCalibratingMax ? Color.red : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.trailing)
                        .padding(.bottom)
                }
                .onAppear {
                    calibrationMaxThresholdCancellable = setInfoModel.imageDifference.calibrationMaxCeiling
                        .receive(on: RunLoop.main)
                        .sink { newThresholdMax in
                            self.calibrationMaxThreshold = newThresholdMax
                            setInfoModel.userSettings.calibrationMax = newThresholdMax
                        }
                    isCalibratingMaxCancellable = setInfoModel.imageDifference.$isCalibratingMax
                        .receive(on: RunLoop.main)
                        .sink { isCalibratingMax in
                            self.isCalibratingMax = isCalibratingMax
                        }
                }
                
            }
        }
    }
}
