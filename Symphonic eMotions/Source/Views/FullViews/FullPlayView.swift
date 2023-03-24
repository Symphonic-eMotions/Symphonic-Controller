//
//  PlayView.swift
//  PlayView
//
//  Created by Frans-Jan Wind on 05.07.2022.
//

import SwiftUI
import AudioKit

struct FullPlayView: View {
    
    @ObservedObject var playViewModel: PlayViewModel
    @ObservedObject var mainViewModel: MainViewModel
    
//    @EnvironmentObject var homeKitStore: HomeKitManager
    
    var body: some View {
        
        //        VStack {
        GeometryReader { geometry in
            
            ZStack(alignment: .center){
                
                //Background
                Image(playViewModel.playViewState.currentInstrumentsSet.playViewImages?.background ?? "Logo") .resizable() .scaledToFill() .edgesIgnoringSafeArea(.all)
                
                if playViewModel.playViewState.currentInstrumentsSet.playViewImages?.playViewFeedback == "sunLevel" {
                    
                    LevelSunView(
                        playViewModel: playViewModel,
                        size: geometry.size
                    )
                }
                
                else if playViewModel.playViewState.currentInstrumentsSet.playViewImages?.playViewFeedback == "cameraInstrumenten" {
                    
                    //Video preview and instrument locations
                    VStack{
                        ZStack{
                            //Instruments
                            PlayGridView(
                                playViewModel: playViewModel
                            )
                            
                            //Video
                            VideoPreviewViewRepresetable(
                                playViewModel: playViewModel
                            )
                            .aspectRatio(1.77777, contentMode: .fit)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.secondary))
                            .cornerRadius(10.0)
//                            .opacity( playViewModel.playViewState.displayMode == .both ? 0.5 : 1.0)
                            .opacity(0.5)
                            
                        }
                        .frame(width: 840, height: 840, alignment: .center)
                        .opacity(0.4)
                        Spacer()
                    }
//                    .border(Color.red)
                    
                }
                
                
                
                //Foregound
                Image(playViewModel.playViewState.currentInstrumentsSet.playViewImages?.foreground ?? "Logo") .resizable() .scaledToFill() .edgesIgnoringSafeArea(.all)


                //Back Button
                ZStack{
                    Image(playViewModel.playViewState.currentInstrumentsSet.playViewImages?.backButtonBackground ?? "Logo").resizable().scaledToFit()
                        .padding(.all)
                        .frame(width: 160, height: 160, alignment: .center)
                    Image(playViewModel.playViewState.currentInstrumentsSet.playViewImages?.backButton ?? "Logo" ).resizable().scaledToFit()
                        .padding(.all)
                        .frame(width: 100, height: 100, alignment: .center)
                }
                .frame(width: 160, height: 160, alignment: .center)
                .position(x: 130, y: 130)
                .onTapGesture {
//                    homeKitStore.lampUit()
                    mainViewModel.backButton()
                }
                
                HStack(){
                    //Volume slider
                    VolumeSlider()
                        .frame(width: 300, height: 20)
                        .position(x: 200, y: 900)
                        .tint(Color.purple)
                       .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                       .zIndex(100)
                }
                
            }
        }
    }
}

