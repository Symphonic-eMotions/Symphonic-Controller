//
//  CellScene.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 24/02/2023.
//
import SpriteKit
import SwiftUI

struct DebugCell {
    
    let columns:Int
    let rows:Int
    let celWidth:Float
    let celHeight:Float
    let centerWidth:Float
    let centerHeigth:Float
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.celWidth = 1/Float(columns)
        self.celHeight = 1/Float(rows)
        self.centerWidth = self.celWidth/2
        self.centerHeigth = self.celHeight/2
    }
}

struct InstrumentSetting{
    let name:String
    let color:UIColor
    let shape:String
    let image:String
}

class Container: SKNode { }

class Instrument: SKShapeNode { }

class ImageInstrument: SKSpriteNode { }

//class Receiver {
//
//    var instrumentPart: Instrument!
//    var instrumentPartScale: CGFloat?
//    var instrumentPartMaxIndex: Int = 0
//    var instrumentPartMidiClip: Int = 0
//}


/*
 
 Stappenplan
 √ MoveTo ipv Y-Step naar X-Y Locatie
 √ - Elk instrument moet een x en y collectie krijgen gebasseerd op indexes
 - Background voor actieve cellen
 - - background strokes
 - Adaptive colors from settings
 - - Negative instrument active stroke activator
 - - Stroke invisible on connectd cell
 - Waarom heeft Upbeat Acid gespiegelde X-as
 -
 
 */

class CellScene: SKScene {
    
    var gravityVector: vector_float3!
    var updateLimiter: [Int]!
    
    var debugNumbers: Bool = true
//    var receiver: [Receiver] = []
    
    //GameScene globals to change through update
    //At this moment static 4 instruments
    var instrumentPart0a: Container!
    var instrumentPart0aScale: CGFloat?
    var instrumentPart0aMaxIndex: Int = 0
    var instrumentPart0aMidiClip: Int = 0
    
    var instrumentPart1a: Container!
    var instrumentPart1aScale: CGFloat?
    var instrumentPart1aMaxIndex: Int = 0
    var instrumentPart1aMidiClip: Int = 0
    
    var instrumentPart2a: Container!
    var instrumentPart2aScale: CGFloat?
    var instrumentPart2aMaxIndex: Int = 0
    var instrumentPart2aMidiClip: Int = 0
    
    var instrumentPart3a: Container!
    var instrumentPart3aScale: CGFloat?
    var instrumentPart3aMaxIndex: Int = 0
    var instrumentPart3aMidiClip: Int = 0
    
    var sessionSkin: InstrumentsSet.Skin!
    
    var columns: Int = 0
    var rows: Int = 0
    
    var instrument0Xs: [CGFloat] = []
    var instrument0Ys: [CGFloat] = []
    
    var instrument1Xs: [CGFloat] = []
    var instrument1Ys: [CGFloat] = []
    
    var instrument2Xs: [CGFloat] = []
    var instrument2Ys: [CGFloat] = []
    
    var instrument3Xs: [CGFloat] = []
    var instrument3Ys: [CGFloat] = []
    
    
    //Keep track of current MidiClip to add or remove particle emitter
//    var rememberMidiClips: [Int] = []
    
    //Collect all areas of interest from the instrument settings
    var instrumentPartAreas: [[[Int]]] = []
    
    //Start of Scene funciton
    override func didMove(to view: SKView) {
        
        //At this stage there is a maximum of 4 instruments
        for index in [0,1,2,3] {
            if index == 0 {
                instrumentPart0a = setupInstrument(
                    instrumentIndex: index
                )
                addChild(instrumentPart0a)
            }
            else if index == 1 {
                instrumentPart1a = setupInstrument(
                    instrumentIndex: index
                )
                addChild(instrumentPart1a)
            }
            else if index == 2 {
                instrumentPart2a = setupInstrument(
                    instrumentIndex: index
                )
                addChild(instrumentPart2a)
            }
            else if index == 3 {
                instrumentPart3a = setupInstrument(
                    instrumentIndex: index
                )
                addChild(instrumentPart3a)
            }
        }

        if debugNumbers {
            let cell = DebugCell(columns: columns, rows: rows)
            debugGrid(cell: cell)
        }
        
        physicsBody = SKPhysicsBody()
    }
    
    func setupInstrument(instrumentIndex: Int) -> Container{
        
        updateLimiter[instrumentIndex] = 0
        
        let skin = self.sessionSkin.instruments[instrumentIndex]
        
        let container = Container()
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        if instrumentIndex == 0 {
            x = self.instrument0Xs.first ?? 0
            y = self.instrument0Ys.first ?? 0
        }
        else if instrumentIndex == 1 {
            x = self.instrument1Xs.first ?? 0
            y = self.instrument1Ys.first ?? 0
        }
        else if instrumentIndex == 2 {
            x = self.instrument2Xs.first ?? 0
            y = self.instrument2Ys.first ?? 0
        }
        else if instrumentIndex == 3 {
            x = self.instrument3Xs.first ?? 0
            y = self.instrument3Ys.first ?? 0
        }
        
        print("instrumentIndex: \(instrumentIndex) x: \(x) y: \(y)")
        
        container.position = CGPoint(
            x: x,
            y: y
        )
        
        var instrumentRadius = self.size.width / CGFloat(self.columns + 4)
        var instrument = Instrument(circleOfRadius: instrumentRadius)
        instrument.name = "1stChild"
        instrument.fillColor = .clear
        instrument.strokeColor = skin.color
        instrument.glowWidth = 5
        instrument.alpha = 0.5
        container.addChild(instrument)
        
        instrumentRadius = self.size.width / CGFloat(self.columns + 4)
        instrument = Instrument(circleOfRadius: instrumentRadius)
        instrument.name = "2ndChild"
        instrument.fillColor = skin.color
        instrument.strokeColor = .clear
        instrument.alpha = 0.4
        container.addChild(instrument)
        
        let image = ImageInstrument(imageNamed: skin.image)
        image.name = "image"
        container.addChild(image)
        
        return container
    }

    override func update(_ currentTime: TimeInterval) {
        
        var instrumentIndex: Int!
        var partScale: Double!
        var position: CGPoint!
        
        instrumentIndex = 0
        if self.instrument0Xs.indices.contains(instrumentPart0aMaxIndex){
            //Cello
            
            print("Cello maxIndex \(instrumentPart0aMaxIndex)")
            print(self.instrument0Xs)
            print(self.instrument0Ys)
            
            position = CGPoint(
                x: self.instrument0Xs[instrumentPart0aMaxIndex],
                y: self.instrument0Ys[instrumentPart0aMaxIndex]
            )
            partScale = instrumentPart0aScale ?? 0
            updateInstrument(
                container: instrumentPart0a,
                instrumentIndex: instrumentIndex,
                partScale: partScale,
                position: position
            )
            updateEmitter(
                instrumentIndex: instrumentIndex,
                position: position,
                partScale: partScale,
                midiClip: instrumentPart0aMidiClip
            )
        }
        
        instrumentIndex = 1
        if self.instrument1Xs.indices.contains(instrumentPart1aMaxIndex){
            //Cello
            position = CGPoint(
                x: self.instrument1Xs[instrumentPart1aMaxIndex],
                y: self.instrument1Ys[instrumentPart1aMaxIndex]
            )
            partScale = instrumentPart1aScale ?? 0
            updateInstrument(
                container: instrumentPart1a,
                instrumentIndex: instrumentIndex,
                partScale: partScale,
                position: position
            )
            updateEmitter(
                instrumentIndex: instrumentIndex,
                position: position,
                partScale: partScale,
                midiClip: instrumentPart1aMidiClip
            )
        }
        
        instrumentIndex = 2
        if self.instrument2Xs.indices.contains(instrumentPart2aMaxIndex){
            //Cello
            position = CGPoint(
                x: self.instrument2Xs[instrumentPart2aMaxIndex],
                y: self.instrument2Ys[instrumentPart2aMaxIndex]
            )
            partScale = instrumentPart2aScale ?? 0
            updateInstrument(
                container: instrumentPart2a,
                instrumentIndex: instrumentIndex,
                partScale: partScale,
                position: position
            )
            updateEmitter(
                instrumentIndex: instrumentIndex,
                position: position,
                partScale: partScale,
                midiClip: instrumentPart2aMidiClip
            )
        }
        
        instrumentIndex = 3
        if self.instrument3Xs.indices.contains(instrumentPart3aMaxIndex){
            //Cello
            position = CGPoint(
                x: self.instrument3Xs[instrumentPart3aMaxIndex],
                y: self.instrument3Ys[instrumentPart3aMaxIndex]
            )
            partScale = instrumentPart3aScale ?? 0
            updateInstrument(
                container: instrumentPart3a,
                instrumentIndex: instrumentIndex,
                partScale: partScale,
                position: position
            )
            updateEmitter(
                instrumentIndex: instrumentIndex,
                position: position,
                partScale: partScale,
                midiClip: instrumentPart3aMidiClip
            )
        }
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
    
    func updateEmitter(instrumentIndex: Int, position: CGPoint, partScale: Double, midiClip: Int) -> Void {
        
        //Manual modulo fps limiter
        if self.updateLimiter[instrumentIndex] == 0 {
            
            if let emitter: SKEmitterNode = SKEmitterNode(fileNamed: "MagicParticle") {
                
                let skin = self.sessionSkin.instruments[instrumentIndex]
                emitter.position = position
                emitter.particleColorSequence = nil;
                emitter.particleColorBlendFactor = 1.0;
                emitter.particleColor = skin.color
                emitter.alpha = partScale
                addChild(emitter)
                
                let remover = SKAction.sequence([
                    SKAction.wait(forDuration: 3),
                    SKAction.removeFromParent()
                ])
                emitter.run(remover)
            }
        }
        
        self.updateLimiter[instrumentIndex] += 1
        //Higher MIDI clip index gets lower modulo (more fps)
        if self.updateLimiter[instrumentIndex] >= midiClipToParticle(midiClip: midiClip) {
            self.updateLimiter[instrumentIndex] = 0
        }
    }
    
    func midiClipToParticle(midiClip: Int) -> Int{
        //Higher number are LESS update (updateLimiter)
        let ranges: [Int] = [10,5,2,1]
        if ranges.indices.contains(midiClip) {
            return ranges[midiClip]
        }
        else { return 0 }
    }
    
    
    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
    }
    
    
//    func isMidiClipChanged(currrentClip: Int, insrtumentIndex: Int) -> Bool{
//        if currrentClip != self.rememberMidiClips[insrtumentIndex] {
//            self.rememberMidiClips[insrtumentIndex] = currrentClip
//            return true
//        }
//        else {
//            self.rememberMidiClips[insrtumentIndex] = currrentClip
//            return false
//        }
//    }
    
//    //Make box on tap, first part of this tutorial
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//
//        let location = touch.location(in: self)
//
//        let randomInt = Int.random(in: 10...75)
//
//        let box = SKSpriteNode(color: .green, size: CGSize(width: randomInt, height: randomInt))
//        box.position = location
//        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: randomInt, height: randomInt))
//        box.physicsBody?.restitution = CGFloat(Float.random(in: 0.2...0.8))
//        addChild(box)
//    }
    
    
    func debugGrid(cell: DebugCell) {
        
        var index: Int = 0
        
        for row in 0..<cell.rows {
            
            for column in 0..<cell.columns {
                
                //Calculate the horizontal center of all cells
                let xOffset = CGFloat(Float(column) * cell.celWidth + cell.centerWidth)
                
                //Calculate the vertical center of all cells
                //Reverse columns for mirrored output on x-axis (SpriteKit 0:0 is left bottom, SeM 0:0 is left top)
                let reversedColumn = reverseNumber(number: row, min: 0, max: rows - 1)
//                let yOffset = CGFloat(Float(reversedColumn) * cell.celHeight + cell.centerHeigth)
                
                //For debuging we show text in all cells
                let yOffsetText = CGFloat(Float(reversedColumn) * cell.celHeight + cell.centerHeigth - 0.013)
                
                let debugNumber = setUpDebugNumbers(index: index, xOffset: xOffset, yOffsetText: yOffsetText)
                addChild(debugNumber)
            
                index += 1
            }
        }
    }
    
    func setUpDebugNumbers(index:Int, xOffset: CGFloat, yOffsetText: CGFloat) -> SKLabelNode {
        
        let indexText = SKLabelNode(fontNamed: "Arial")
        indexText.text = "\(index)"
        indexText.fontSize = 50
        indexText.fontColor = SKColor.green
        indexText.alpha = 0.5
        indexText.position = CGPoint(x: size.width * xOffset, y: size.height * yOffsetText)
        
        return indexText
    }
}
