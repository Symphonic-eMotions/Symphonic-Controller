//
//  MovementView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 26/06/2023.
//

import SwiftUI

struct MovementView: View {
    
    @AppStorage(UserDefaultsKeys.currentUrl) var currentUrl: String = "Introduction"
    @AppStorage(UserDefaultsKeys.videoFeedback) var videoFeedback: Double = 0.5
    @ObservedObject var setInfoModel: SetInfoModel
    @Binding public var sessionDisplay: SessionDisplay
    @Binding public var sessionDisplaySub: SessionDisplay
    
    @State private var selectedButton: Int? = nil
    @State var setIsPlaying: Bool = false;
    @State var hasTested: Bool = false
    
    @State private var rotationSpeed: Double = 0
    
    var body: some View {
        
        ZStack(alignment: .topLeading){
            
            VStack(spacing: 0) {
                
                //Visual Feedback
//                AmoebaView(setInfoModel: setInfoModel)
                
                VStack {
                    WarpHoleView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                
                Spacer()
                
                ZStack(alignment: .topLeading){
                    
                    VStack{
                        
                        //4 movement buttons
                        let imageSide = UIScreen.main.bounds.width * 0.12
                        HStack(spacing: 20) {
                            ForEach(0..<4) { column in
                                Button(action: {
                                    self.selectedButton = column
                                    self.videoFeedback = self.setInfoModel.movementSetting(id: column)
                                }) {
                                    ZStack{
                                        Rectangle()
                                            .frame(width: imageSide, height: imageSide)
                                            .foregroundColor(.clear)
                                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                            .background( self.selectedButton == column ? Color.accentColor : Color.gray)

                                        Image("movementId\(column)")
                                            .resizable()
                                            .frame(width: imageSide, height: imageSide)
                                    }
                                }
                            }
                        }
                        
                        //Play and continue
                        HStack {
                            
                            //Play / stop button
                            ZStack {
                                Rectangle()
                                    .frame(width: 200, height: 60)
                                    .foregroundColor(.clear)
                                    .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                    .background( Color.accentColor )
                                
                                if setIsPlaying {
                                    Text(NSLocalizedString("Stop set", comment: ""))
                                        .font(.system(size: 30))
                                        .padding()
                                }
                                else{
                                    Text(NSLocalizedString("Test set", comment: ""))
                                        .font(.system(size: 30))
                                        .padding()
                                }
                            }
                            .onTapGesture {
                                
                                hasTested = true
                                
                                if setIsPlaying {
                                    setInfoModel.tapToggleConductor()
                                    self.setIsPlaying = false
                                }
                                else{
                                    setInfoModel.tapToggleConductor()
                                    self.setIsPlaying = true
                                }
                            }
                            
                            //Title
                            Text(NSLocalizedString("Movement amount", comment: ""))
                                .font(.system(size: 40))
                                .padding()
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: 200, height: 60)
                                    .foregroundColor(.clear)
                                    .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
                                    .background( Color.accentColor )
                                
                                Text(NSLocalizedString("Continue", comment: ""))
                                    .font(.system(size: 30))
                                    .padding()
                            }
                            .onTapGesture {
                                withAnimation {
                                    
                                    setInfoModel.tapStopAudioEngine()
                                    
                                    sessionDisplay = .demo
                                    sessionDisplaySub = .demo
                                }
                            }
                            .disabled(!hasTested)
                        }
                    }
                }
            }
            .onAppear{
                
                print("MovementView page: \(sessionDisplay) / \(sessionDisplaySub)")
                
                setInfoModel.tapStopAudioEngine()
                
                //Load set
                setInfoModel.tapSetRow(filePath: "Introductie.json")
                
                //Let @AppStorage know what is current
                currentUrl = "Introductie.json"
            }
            
            //Back button
            ZStack {
                Image(systemName: "arrowshape.backward")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .onTapGesture {
                withAnimation {
                    //Paginering
                    let pages:[SessionDisplay:SessionDisplay] = [.page02:.page01,.page03:.page02,.page04:.page03,.page05:.page04]
                    if let prevPage = pages[sessionDisplaySub] {
                        sessionDisplaySub = prevPage
                    }
                }
            }
            
        }
    }
}
