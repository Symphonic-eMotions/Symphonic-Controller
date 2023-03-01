//
//  CellScene.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 24/02/2023.
//
import SpriteKit
import SwiftUI

struct Cell {
    
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

//class Receiver {
//
//    var instrumentPart: Instrument!
//    var instrumentPartScale: CGFloat?
//    var instrumentPartMaxIndex: Int = 0
//    var instrumentPartMidiClip: Int = 0
//}

class CellScene: SKScene {
    
    var gravityVector: vector_float3!
    var updateLimiter: Int = 0
    
    var debugNumbers: Bool = false
//    var videoOpacity: Float = 0
    
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
    
    var instrumentXs: [CGFloat] = []
    var yStep: CGFloat = 0
//    var rememberYs: [CGFloat] = []
    var instrumentYs: [CGFloat] = []
    //Keep track of current MidiClip to add or remove particle emitter
    var rememberMidiClips: [Int] = []
    
    //Collect all areas of interest from the instrument settings
    var instrumentPartAreas: [[[Int]]] = []
    
    //Start of Scene funciton
    override func didMove(to view: SKView) {
        
        //At this stage there is a maximum of 4 instruments
        for (index,_) in instrumentXs.enumerated() {
            if index == 0 {
                instrumentPart0a = setupInstrument(
                    instrumentIndex: index,
                    gravityGroup: 0x1 << 0
                )
                addChild(instrumentPart0a)
            }
            else if index == 1 {
                instrumentPart1a = setupInstrument(
                    instrumentIndex: index,
                    gravityGroup: 0x1 << 1
                )
                addChild(instrumentPart1a)
            }
            else if index == 2 {
                instrumentPart2a = setupInstrument(
                    instrumentIndex: index,
                    gravityGroup: 0x1 << 2
                )
                addChild(instrumentPart2a)
            }
            else if index == 3 {
                instrumentPart3a = setupInstrument(
                    instrumentIndex: index,
                    gravityGroup: 0x1 << 3
                )
                addChild(instrumentPart3a)
            }
        }

        
        if debugNumbers {
            let cell = Cell(columns: columns, rows: rows)
            debugGrid(cell: cell)
        }
        
        physicsBody = SKPhysicsBody()
    }
    
    func setupInstrument(instrumentIndex: Int, gravityGroup: UInt32) -> Container{
        
        let skin = self.sessionSkin.instruments[instrumentIndex]
        
        let container = Container()
        container.position = CGPoint(
            x: self.instrumentXs[instrumentIndex],
            y: self.instrumentYs[instrumentIndex]
        )
        
        var instrumentRadius = self.size.width / CGFloat(self.columns + 2)
        var instrument = Instrument(circleOfRadius: instrumentRadius)
        instrument.name = "1stChild"
        instrument.fillColor = .clear
        instrument.strokeColor = skin.color
        instrument.glowWidth = 5
        container.addChild(instrument)
        
        instrumentRadius = self.size.width / CGFloat(self.columns + 3)
        instrument = Instrument(circleOfRadius: instrumentRadius)
        instrument.name = "2ndChild"
        instrument.fillColor = skin.color
        instrument.strokeColor = .clear
        instrument.alpha = 0.8
//        instrument.glowWidth = 5
        container.addChild(instrument)
        
        return container
    }

    override func update(_ currentTime: TimeInterval) {
        
        //        let movementSpeed = 0.35
        var instrumentIndex: Int!
        var partScale: Double!
        var position: CGPoint!
        
        instrumentIndex = 0
        if self.instrumentXs.indices.contains(instrumentIndex){
            //Cello
            position = CGPoint(
                x: self.instrumentXs[instrumentIndex],
                y: maxIndexToY(maxIndex: instrumentPart0aMaxIndex)
            )
            partScale = instrumentPart0aScale ?? 0
            updateInstrument(
                container: instrumentPart0a,
                instrumentIndex: instrumentIndex,
                partScale: partScale,
                position: position
            )
            updateEmitter(instrumentIndex: instrumentIndex, position: position, partScale: partScale)
        }
        
        instrumentIndex = 1
        if self.instrumentXs.indices.contains(instrumentIndex){
            //Cello
            position = CGPoint(
                x: self.instrumentXs[instrumentIndex],
                y: maxIndexToY(maxIndex: instrumentPart1aMaxIndex)
            )
            partScale = instrumentPart1aScale ?? 0
            updateInstrument(
                container: instrumentPart1a,
                instrumentIndex: instrumentIndex,
                partScale: partScale,
                position: position
            )
            updateEmitter(instrumentIndex: instrumentIndex, position: position, partScale: partScale)
        }
        
        instrumentIndex = 2
        if self.instrumentXs.indices.contains(instrumentIndex){
            //Cello
            position = CGPoint(
                x: self.instrumentXs[instrumentIndex],
                y: maxIndexToY(maxIndex: instrumentPart2aMaxIndex)
            )
            partScale = instrumentPart2aScale ?? 0
            updateInstrument(
                container: instrumentPart2a,
                instrumentIndex: instrumentIndex,
                partScale: partScale,
                position: position
            )
            updateEmitter(instrumentIndex: instrumentIndex, position: position, partScale: partScale)
        }
        
        instrumentIndex = 3
        if self.instrumentXs.indices.contains(instrumentIndex){
            //Cello
            position = CGPoint(
                x: self.instrumentXs[instrumentIndex],
                y: maxIndexToY(maxIndex: instrumentPart3aMaxIndex)
            )
            partScale = instrumentPart3aScale ?? 0
            updateInstrument(
                container: instrumentPart3a,
                instrumentIndex: instrumentIndex,
                partScale: partScale,
                position: position
            )
            updateEmitter(instrumentIndex: instrumentIndex, position: position, partScale: partScale)
        }
        
        self.updateLimiter += 1
        if self.updateLimiter > 10 { self.updateLimiter = 0 }
        
    }
    
    func updateInstrument(container: Container, instrumentIndex: Int, partScale: Double, position: CGPoint) -> Void{
        container.run(SKAction.move(to: position, duration: 0.35))
        container.childNode(withName: "1stChild")!.setScale(CGFloat(partScale))
        container.childNode(withName: "2ndChild")!.setScale(CGFloat(partScale*partScale*partScale))
    }
    
    func updateEmitter(instrumentIndex: Int, position: CGPoint, partScale: Double) -> Void {
        
        if self.updateLimiter == 0 {
            
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
    }
    
    func isMidiClipChanged(currrentClip: Int, insrtumentIndex: Int) -> Bool{
        if currrentClip != self.rememberMidiClips[insrtumentIndex] {
            self.rememberMidiClips[insrtumentIndex] = currrentClip
            return true
        }
        else {
            self.rememberMidiClips[insrtumentIndex] = currrentClip
            return false
        }
    }
    
    func midiClipToParticle(midiClip: Int) -> Int{
        let ranges: [Int] = [5,10,25,50]
        if ranges.indices.contains(midiClip) {
            return ranges[midiClip]
        }
        else { return 0 }
    }
    
    func maxIndexToY(maxIndex: Int) -> CGFloat {
        
        var y: CGFloat = -100
        
        y += CGFloat(maxIndex) * self.yStep
        
        return y
    }
    
    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
    }
    
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
    
    
    func debugGrid(cell: Cell) {
        
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
