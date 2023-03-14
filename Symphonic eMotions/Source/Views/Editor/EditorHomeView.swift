//
//  EditorHomeView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2023.
//

import SwiftUI

struct EditorHomeView: View {
    var body: some View {
        VStack{
            Spacer().frame(height:70)
            HStack {
                
                Image("LogoColor")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    
                    
                Text("Symphonic eMotions Editor")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .padding(.leading, 40)
                
            }
            Spacer()
        }
        
    }
}
