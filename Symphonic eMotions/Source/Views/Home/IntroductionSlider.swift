//
//  IntroductionSlider.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/06/2023.
//

import SwiftUI

struct IntroductionSlider: View {
    
    var label: LocalizedStringKey
    @Binding var value: Double
    var minValue: Double = 0
    var maxValue: Double = 1
    var withPercentage: CGFloat = 0.7
    
    init(
        label: LocalizedStringKey,
        value: Binding<Double>,
        minValue: Double = 0,
        maxValue: Double = 1,
        withPercentage: CGFloat = 0.7
    ) {
        self.label = label
        _value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.withPercentage = withPercentage
    }
    
    func convertToDistance(value: Double) -> Int {
        return 99 - Int((value * 98).rounded())
    }
    func convertToSensitivity(value: Double) -> Int {
        return 1 + Int((value * 99).rounded())
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                Slider(value: $value, in: minValue...maxValue)
                    .foregroundColor(.accentColor)
                    .frame(width: geometry.size.width * withPercentage)
                
                HStack {
                    Text(label)
                        .font(.system(size: 40))
                        .padding()
                    
                    if label == "Distance" {
                        
                        Text("\(convertToDistance(value: value))")
                            .font(.system(size: 40))
                    }
                    else if label == "Sensitivity"{
                        
                        Text("\(convertToSensitivity(value: value))")
                            .font(.system(size: 40))
                    }
                }
            }
        }
        .frame(height: 50.0)
    }
}
