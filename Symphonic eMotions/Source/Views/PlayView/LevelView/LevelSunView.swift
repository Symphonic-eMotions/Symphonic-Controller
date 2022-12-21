//
//  LevelSunView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 20/07/2022.
//

import SwiftUI

struct GrowingSun: View {
    
    @Binding var value: Float
    
    var size: CGSize
    let sunNumber: Int
    
    var sunOpacities: [Double] = [0.5,0.75,0.85,1.0]
    var sunMaxSizes: [Float] = [1.0,0.9,0.8,0.7]
    
    var body: some View {
        
        let sizeScaled: CGFloat = size.height * CGFloat(value * sunMaxSizes[sunNumber])
        
//        let _ = print("sunNumber: \(sunNumber) size: \(sizeScaled) value: \(value) sunMaxSizes: \(sunMaxSizes[sunNumber]) sunOpacities: \(sunOpacities[sunNumber])")
        
        Image("FullPlayFarmSun")
            .resizable()
            .frame(width: sizeScaled, height: sizeScaled, alignment: .center)
            .opacity(sunOpacities[sunNumber])
    }
}


struct LevelSunView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    var size: CGSize
    
    var body: some View {
        ZStack{
            ForEach( 0..<4 ) { sunNumber in
                
                if Int(playViewModel.leveling.currentSetLevelSubject.value) >= sunNumber {
                    GrowingSun(
                        value: .init(
                            get: {
                                let currentBarLevel = Float(max(0, playViewModel.leveling.currentSetLevelSubject.value - Double(sunNumber) ) )
                                return max(0, min(1, currentBarLevel))
                            },
                            set: { _ in }
                        ),
                        size: size,
                        sunNumber: sunNumber
                    )
                }
            }
        }
    }
}

