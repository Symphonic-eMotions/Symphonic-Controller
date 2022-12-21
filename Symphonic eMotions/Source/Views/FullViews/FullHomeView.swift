//
//  FullHomeView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 05/07/2022.
//

import SwiftUI
import AudioKit

struct FullHomeViewState {
    let setCollections: Sets
    let currentInstrumentSet: InstrumentsSet
    var animationKeep: [Int: Bool]
    //I need something to itterate with
//    let images: [Image]
//    let imageAnimate: [Bool]
}

final class FullHomeViewModel: ObservableObject {
    
    @Published var state: FullHomeViewState
    let rowSelected: (InstrumentsSet) -> ()
    var conductor: Conductor
    
    init(
        state: FullHomeViewState,
        rowSelected: @escaping (InstrumentsSet) -> (),
        conductor: Conductor
    ) {
        self.state = state
        self.rowSelected = rowSelected
        self.conductor = conductor
    }
    
    func tapLoadInstrumentSet(selectedCollection: Set) {
        
        //Get sound effect note number from sets file
        let noteNumber = MIDINoteNumber(selectedCollection.noteNumber ?? 1)
        //Play the note number in the sound effetcs sampler
        conductor.playSoundEffect(midi: noteNumber)
//        print("Play: \(noteNumber)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            //Load the set in the "real" engine
            let instrumentSet = AppUtils.loadInstrumentSet(json: selectedCollection.config)
            self.rowSelected(instrumentSet)
        }
    }
}

struct FullHomeView: View {
    
    @ObservedObject var fullHomeViewModel: FullHomeViewModel
    @EnvironmentObject var homeKitStore: HomeKitManager
    
    var body: some View {
        
        ZStack {
            //Background
            Image("FullHomeViewBackground") .resizable() .scaledToFill() .edgesIgnoringSafeArea(.all)
            
            //Musical key background animation
            MusicalKeysView(fullHomeViewModel:fullHomeViewModel)
            
            //Big Ass Buttons
            HStack {
                //Loop through sets for main buttons
                ForEach( fullHomeViewModel.state.setCollections.sets, id: \.self ) { setCollection in
                    ZStack{
                        Image(setCollection.imageBackground ?? "Logo").resizable().scaledToFit()
                            .padding(.all)
                        Image(setCollection.image ?? "Logo" ).resizable().scaledToFit()
                            .padding(.all)
                            .frame(width: 300, height: 300, alignment: .center)
                        
                            .scaleEffect( fullHomeViewModel.state.animationKeep[Int(setCollection.id)!]! ? 2 : 1 )
                            .opacity(fullHomeViewModel.state.animationKeep[Int(setCollection.id)!]! ? 0.1 : 1 )
                    }
                    
                    .onTapGesture {
                        
                        homeKitStore.lampAan()
                        
                        let duration: Double = 3.5
                        let baseAnimation = Animation.easeInOut(duration: duration)
                        let repeated = baseAnimation.repeatForever(autoreverses: false)

                        withAnimation(repeated) {
                            
                            fullHomeViewModel.state.animationKeep[Int(setCollection.id)!]!.toggle()
                            
                            if fullHomeViewModel.state.animationKeep[Int(setCollection.id)!]! {
                                
                                fullHomeViewModel.tapLoadInstrumentSet(selectedCollection: setCollection)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MusicalKeysView: View {
    
    @ObservedObject var fullHomeViewModel: FullHomeViewModel
//    @State var animationIsRunning = false
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    @State private var scale = [Double](repeating: Double.random(in: 0.1...0.9), count: 50)
    @State private var opacity = [Double](repeating: Double.random(in: 0...0.5), count: 50)
    
    var body: some View {
        
//        if !animationIsRunning {
        
            ZStack {
            
            ForEach(0..<50) { index in
                
                Image("FullHomeMusicKey")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60, alignment: .center)
                    .position(
                        x: CGFloat.random(in: 0..<screenWidth),
                        y: CGFloat.random(in: 0..<screenHeight)
                    )
                    //This sits here for ristricting position animation
                    //This method gets depricated
                    //. animation(nil)
                    .opacity(opacity[index])
                    .scaleEffect(scale[index])
                    .onAppear {
                        
                        let duration = Double.random(in: 8...22)
                        let baseAnimation = Animation.easeInOut(duration: duration)
                        let repeated = baseAnimation.repeatForever(autoreverses: true)

                        withAnimation(repeated) {
                            scale[index] = Double.random(in: 1...3)
                            opacity[index] = Double.random(in: 0.5...1)
                        }
                        
                    }
//                }
            }
        }
//        }
    }
}
