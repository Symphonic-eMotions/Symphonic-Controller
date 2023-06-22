//
//  IntroductionImage.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/06/2023.
//

import SwiftUI

struct IntroductionImage: View {
    
    public var imageName: String
    public var customWidth: Double
    public var customHeight: Double
    
    var body: some View {
        let imageWidth = UIScreen.main.bounds.width * customWidth
        let imageHeight = UIScreen.main.bounds.height * customHeight
        
        HStack {
            Spacer()
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageWidth, height: imageHeight, alignment: .center)
            
            Spacer()
        }
        .padding(.top, 40)
    }
}
