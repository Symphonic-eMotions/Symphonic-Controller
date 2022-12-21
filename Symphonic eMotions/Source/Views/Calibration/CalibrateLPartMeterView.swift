//
//  CalibrateLPartMeterView.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 06/11/2022.
//

import SwiftUI

struct CalibrateLPartMeterView: View {
    
    @ObservedObject var calibrationModel: CalibrationModel
    @State var updateView: Int
    @Binding var value: Float
    
    var body: some View {
        
        let calibrationPartMeterSteps = calibrationModel.calibrationState.sessionSettings.calibrationPartMeterSteps
        
        HStack{
            
            VStack{
                ForEach(0...calibrationPartMeterSteps, id: \.self){ i in
                    calibrationModel.partMeter(indicatorNr: i, currentValue: value)
                }
            }
            Spacer()
            calibrationModel.partThumb(currentValue: value)
                .padding()
                .font(.system(size: 100))
        }
        
        
    }
}
