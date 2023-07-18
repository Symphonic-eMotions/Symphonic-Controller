//
//  InstrumentLocations.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 17/07/2023.
//

import SpriteKit
import SwiftUI
import Combine

var spriteKitParts0a = PassthroughSubject<(Int,Int,Double), Never>()
var spriteKitParts1a = PassthroughSubject<(Int,Int,Double), Never>()
var spriteKitParts2a = PassthroughSubject<(Int,Int,Double), Never>()
var spriteKitParts3a = PassthroughSubject<(Int,Int,Double), Never>()

struct InstrumentLocations: UIViewRepresentable {
    
    var sceneSize: CGSize
    var sceneSkin: InstrumentsSet.Skin
    var instrument0Positions: [CGPoint]
//    var instrument1Positions: [CGPoint]
//    var instrument2Positions: [CGPoint]
//    var instrument3Positions: [CGPoint]
    
    class Coordinator {
        
        var scene: InstrumentLocationScene
        var cancellable0: AnyCancellable?
//        var cancellable1: AnyCancellable?
//        var cancellable2: AnyCancellable?
//        var cancellable3: AnyCancellable?
        
        init(
            sceneSize: CGSize,
            scene: InstrumentLocationScene
        ) {
            
            self.scene = scene
            
            self.cancellable0 = spriteKitParts0a.sink { [weak self] (int1, int2, double) in
                self?.scene.instrumentPart0aMaxIndex = int1
                self?.scene.instrumentPart0aMidiClip = int2
                self?.scene.instrumentPart0aScale = double
            }
//            self.cancellable1 = spriteKitParts1a.sink { [weak self] (int1, int2, double) in
//                self?.scene.instrumentPart1aMaxIndex = int1
//                self?.scene.instrumentPart1aMidiClip = int2
//                self?.scene.instrumentPart1aScale = double
//            }
//            self.cancellable2 = spriteKitParts2a.sink { [weak self] (int1, int2, double) in
//                self?.scene.instrumentPart2aMaxIndex = int1
//                self?.scene.instrumentPart2aMidiClip = int2
//                self?.scene.instrumentPart2aScale = double
//            }
//            self.cancellable3 = spriteKitParts3a.sink { [weak self] (int1, int2, double) in
//                self?.scene.instrumentPart3aMaxIndex = int1
//                self?.scene.instrumentPart3aMidiClip = int2
//                self?.scene.instrumentPart3aScale = double
//            }
        }
        
        deinit {
            cancellable0?.cancel()
//            cancellable1?.cancel()
//            cancellable2?.cancel()
//            cancellable3?.cancel()
        }
    }
    
    class InstrumentLocationScene: SKScene {
        
        var sceneSkin: InstrumentsSet.Skin!
        var instrument0Positions: [CGPoint]
//        var instrument1Positions: [CGPoint]
//        var instrument2Positions: [CGPoint]
//        var instrument3Positions: [CGPoint]
        
        init(
            sceneSize: CGSize,
            sceneSkin: InstrumentsSet.Skin,
            instrument0Positions: [CGPoint]
//            ,
//            instrument1Positions: [CGPoint],
//            instrument2Positions: [CGPoint],
//            instrument3Positions: [CGPoint]
        ) {
            self.sceneSkin = sceneSkin
            self.instrument0Positions = instrument0Positions
//            self.instrument1Positions = instrument1Positions
//            self.instrument2Positions = instrument2Positions
//            self.instrument3Positions = instrument3Positions
            super.init(size: sceneSize)  // changed from CGSize()
        }
    
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var tiles0: Tiles!
        var instrumentPart0a: Container!
        var instrumentPart0aScale: CGFloat?
        var instrumentPart0aMaxIndex: Int = 0
        var instrumentPart0aMidiClip: Int = 0
        var instrument0Sizes: [CGSize] = []
        
//        var tiles1: Tiles!
//        var instrumentPart1a: Container!
//        var instrumentPart1aScale: CGFloat?
//        var instrumentPart1aMaxIndex: Int = 0
//        var instrumentPart1aMidiClip: Int = 0
//        var instrument1Sizes: [CGSize] = []
//
//        var tiles2: Tiles!
//        var instrumentPart2a: Container!
//        var instrumentPart2aScale: CGFloat?
//        var instrumentPart2aMaxIndex: Int = 0
//        var instrumentPart2aMidiClip: Int = 0
//        var instrument2Sizes: [CGSize] = []
//
//        var tiles3: Tiles!
//        var instrumentPart3a: Container!
//        var instrumentPart3aScale: CGFloat?
//        var instrumentPart3aMaxIndex: Int = 0
//        var instrumentPart3aMidiClip: Int = 0
//        var instrument3Sizes: [CGSize] = []
        
        var columns: Int = 0
        var rows: Int = 0
        
        override func didMove(to view: SKView) {
            
            instrumentPart0a = setupInstrument(instrumentIndex: 0)
            addChild(instrumentPart0a)
//            if self.sceneSkin.name != "free" {
//                tiles0 = setUpBackgrounds(instrumentIndex: index)
//                addChild(tiles0)
//            }
            
//            instrumentPart1a = setupInstrument(instrumentIndex: 1)
//            addChild(instrumentPart1a)
//
//            instrumentPart2a = setupInstrument(instrumentIndex: 2)
//            addChild(instrumentPart2a)
//
//            instrumentPart3a = setupInstrument(instrumentIndex: 3)
//            addChild(instrumentPart0a)
        }
        
        override func update(_ currentTime: TimeInterval) {
            
//            var instrumentIndex: Int!
            var partScale: Double!
            var position: CGPoint!
            
//            print("InstrumentLocationScene \(String(describing: instrumentPart0aScale))")
            
//            instrumentIndex = 0
            if self.instrument0Positions.indices.contains(instrumentPart0aMaxIndex){
                
                //First configured instrument
                position = self.instrument0Positions[instrumentPart0aMaxIndex]
                partScale = instrumentPart0aScale ?? 0
                
//                if !self.isPlaying { partScale = 0 }
                
                updateInstrument(
                    container: instrumentPart0a,
                    instrumentIndex: 0,
                    partScale: partScale,
                    position: position
                )
                
//                updateEmitter(
//                    instrumentIndex: 0,
//                    position: position,
//                    partScale: partScale,
//                    midiClip: instrumentPart0aMidiClip
//                )
            }
            
        }
        
        //MARK: Setup instrument
        func setupInstrument(instrumentIndex: Int) -> Container{
            
//            updateLimiter[instrumentIndex] = 0
            
            let skin = self.sceneSkin.instruments[instrumentIndex]
            
            let container = Container()
            
            if instrumentIndex == 0 {
                container.position = self.instrument0Positions.first ?? CGPoint()
            }
//            else if instrumentIndex == 1 {
//                container.position = self.instrument1Positions.first ?? CGPoint()
//            }
//            else if instrumentIndex == 2 {
//                container.position = self.instrument2Positions.first ?? CGPoint()
//            }
//            else if instrumentIndex == 3 {
//                container.position = self.instrument3Positions.first ?? CGPoint()
//            }
            
            var instrumentRadius = self.size.width / CGFloat(self.columns + 4)
            var instrument = Instrument(circleOfRadius: instrumentRadius)
            instrument.name = "1stChild"
            instrument.fillColor = .clear
            instrument.strokeColor = skin.uiColor
            instrument.glowWidth = 5
            instrument.alpha = 0.5
            container.addChild(instrument)
            
            instrumentRadius = self.size.width / CGFloat(self.columns + 4)
            instrument = Instrument(circleOfRadius: instrumentRadius)
            instrument.name = "2ndChild"
            instrument.fillColor = skin.uiColor
            instrument.strokeColor = .clear
            instrument.alpha = 0.4
            container.addChild(instrument)
            
            let image = ImageInstrument(imageNamed: skin.image)
            image.name = "image"
            container.addChild(image)
            
            return container
        }
        
        func updateInstrument(container: Container, instrumentIndex: Int, partScale: Double, position: CGPoint) -> Void {
            
            //Maybe connect duration to rampUp value?
            container.run(SKAction.move(to: position, duration: 0.35))
            //Stroke circle
            container.childNode(withName: "1stChild")!.setScale(CGFloat(partScale))
            //Solid circle
            container.childNode(withName: "2ndChild")!.setScale(CGFloat(partScale*partScale*partScale*0.7))
            //Image
            container.childNode(withName: "image")!.setScale(CGFloat(partScale*partScale*partScale*partScale*2.5))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            sceneSize: self.sceneSize, scene: InstrumentLocationScene(
                sceneSize: self.sceneSize,
                sceneSkin: self.sceneSkin,
                instrument0Positions: self.instrument0Positions
//                ,
//                instrument1Positions: self.instrument1Positions,
//                instrument2Positions: self.instrument2Positions,
//                instrument3Positions: self.instrument3Positions
            )
        )
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: UIScreen.main.bounds)
        view.presentScene(context.coordinator.scene)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
