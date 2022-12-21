//
//  CalibrateLightView.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 06/11/2022.
//

import SwiftUI

struct CalibrateLightView: View {
    
    @ObservedObject var calibrationModel: CalibrationModel
    @State var updateView: Int
    
    var body: some View {
        
        let imageMaxStepAmountLight: Int = calibrationModel.calibrationState.sessionSettings.imageMaxStepAmountLight
        
        VStack{
            ForEach((0-imageMaxStepAmountLight)...imageMaxStepAmountLight, id: \.self){ i in
                ZStack {
                    calibrationModel.lightIndicator(
                        indicatorNr: i
                    )
                }
            }
        }
    }
}
