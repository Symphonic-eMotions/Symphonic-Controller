//
//  GridView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 27/03/2024.
//

import SwiftUI

struct GridView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @ObservedObject var opacityController: CellOpacityController
    
    let rows: Int
    let columns: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: self.columns)
        let totalVerticalSpacing = CGFloat(self.rows - 1) * 20
        let cellHeight = (height - totalVerticalSpacing - 40) / CGFloat(self.rows)
        
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0..<self.rows * self.columns, id: \.self) { index in
                let color: Color = [.red, .blue, .green, .yellow][index % 4]
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 2)
                    .background(color.opacity(0.2))
                    .frame(width: width / CGFloat(self.columns) - 30, height: cellHeight)
                    .opacity(opacityController.opacities[index])
            }
        }
        .padding(20)
        .onChange(of: setInfoModel.setSettings.maxIndex) { newIndex in
            opacityController.triggerEnvelope(forCell: newIndex)
        }
        .frame(width: width, height: height) // Gebruik de externe afmetingen voor het bepalen van de grootte van de GridView
    }
}


//struct GridView: View {
//    
//    @ObservedObject var setInfoModel: SetInfoModel
//    @ObservedObject var opacityController: CellOpacityController
//    
//    let rows: Int
//    let columns: Int
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let width = geometry.size.width
//            let height = geometry.size.height
//            let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: self.columns)
//            let totalVerticalSpacing = CGFloat(self.rows - 1) * 20
//            let cellHeight = (height - totalVerticalSpacing - 40) / CGFloat(self.rows)
//            
//            LazyVGrid(columns: columns, spacing: 20) {
//                ForEach(0..<self.rows * self.columns, id: \.self) { index in
//                    
//                    let color: Color = [.red, .blue, .green, .yellow][index % 4]
//                    
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(color, lineWidth: 2)
//                        .background(color.opacity(0.2))
//                        .frame(width: width / CGFloat(self.columns) - 30, height: cellHeight)
//                        // Pas hier de opacity aan voor de hele cel
//                        .opacity(opacityController.opacities[index])
//                }
//            }
//            .padding(20)
//            .onChange(of: setInfoModel.setSettings.maxIndex) { newIndex in
//                opacityController.triggerEnvelope(forCell: newIndex)
//            }
//        }
//    }
//}
