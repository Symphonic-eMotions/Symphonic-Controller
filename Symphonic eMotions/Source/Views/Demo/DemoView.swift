//
//  StartView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 23/05/2023.
//

import SwiftUI

struct DemoView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    @EnvironmentObject var fileController: FileController
    
    var body: some View {
        
        VStack{
            
            Spacer().frame(height:70)
            HStack {
                
                Image("LogoColor")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .cornerRadius(10)
                    .padding(.trailing)
                
                
                Text("Symphonic eMotions")
                    .font(.largeTitle)
                    .scaleEffect(1.2)
                    .fontWeight(.regular)
                    .padding(.leading, 40)
            }
            Spacer().frame(height:35)
            
            //Play demo set button
            HStack(spacing: 20){
                
//                HStack {
//                    Image(systemName: "play.fill")
//                        .foregroundColor(.white)
//                        .font(.system(size: 30))
//
//                    Text(NSLocalizedString("Demo set", comment: ""))
//                        .foregroundColor(.white)
//                        .font(.headline)
//                        .padding(.trailing)
//                        .disabled(true)
//                }
//                .padding()
//                .background(Color.accentColor)
//                .cornerRadius(10.0)
//                .onTapGesture {
//
//                    print("Play demo set")
//                }
                
            }
            
            HStack{
                Text(NSLocalizedString("Welcome home", comment: ""))
                    .font(.title)
                    .scaleEffect(1.1)
                    .padding(.top, 70)
                    .padding(.trailing, 100)
                    .padding(.leading, 100)
                
            }
            Spacer()
            
            FooterView()
        }
    }
}
