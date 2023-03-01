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

class Instrument: SKShapeNode { }

class Receiver {
    
    var instrumentPart: Instrument!
    var instrumentPartScale: CGFloat?
    var instrumentPartMaxIndex: Int = 0
    var instrumentPartMidiClip: Int = 0
}

class CellScene: SKScene {
    
    var gravityVector: vector_float3!
    
    var debugNumbers: Bool = false
//    var videoOpacity: Float = 0
    
    var receiver: [Receiver] = []
    
    //GameScene globals to change through update
    //At this moment static 4 instruments
    var gravityNode0: SKFieldNode!
    var instrumentPart0a: Instrument!
    var instrumentPart0aScale: CGFloat?
    var instrumentPart0aMaxIndex: Int = 0
    
    var gravityNode1: SKFieldNode!
    var instrumentPart1a: Instrument!
    var instrumentPart1aScale: CGFloat?
    var instrumentPart1aMaxIndex: Int = 0
    
    var gravityNode2: SKFieldNode!
    var instrumentPart2a: Instrument!
    var instrumentPart2aScale: CGFloat?
    var instrumentPart2aMaxIndex: Int = 0
    
    var gravityNode3: SKFieldNode!
    var instrumentPart3a: Instrument!
    var instrumentPart3aScale: CGFloat?
    var instrumentPart3aMaxIndex: Int = 0
    
    var sessionSkin: InstrumentsSet.Skin!
    
    var columns: Int = 0
    var rows: Int = 0
    
    var instrumentXs: [CGFloat] = []
    var yStep: CGFloat = 0
//    var rememberYs: [CGFloat] = []
    var instrumentYs: [CGFloat] = []
    
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
    
    func setupInstrument(instrumentIndex: Int, gravityGroup: UInt32) -> Instrument{
        
        let skin = self.sessionSkin.instruments[instrumentIndex]
        let instrumentRadius = self.size.width / CGFloat(self.columns + 2)
        
        let instrument = Instrument(circleOfRadius: instrumentRadius)
        
        instrument.position = CGPoint(
            x: self.instrumentXs[instrumentIndex],
            y: self.instrumentYs[instrumentIndex]
        )
        instrument.name = skin.image
        instrument.fillColor = skin.color
        instrument.strokeColor = skin.color
        instrument.glowWidth = 2
        
        instrument.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        instrument.physicsBody?.fieldBitMask = gravityGroup
        instrument.physicsBody?.restitution = 0
        instrument.physicsBody?.friction = 0
//        instrument.physicsBody?.affectedByGravity = false
//        instrument.physicsBody?.pinned = true
        
        if let emitter = SKEmitterNode(fileNamed: "MagicParticle"){
//            emitter.particleColor
            instrument.addChild(emitter)
        }
        
        return instrument
    }
    
    func maxIndexToY(maxIndex: Int) -> CGFloat {
        
        var y: CGFloat = -100
        
        y += CGFloat(maxIndex) * self.yStep
        
        return y
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //Cello
        var position = CGPoint(
            x: self.instrumentXs[0],
            y: maxIndexToY(maxIndex: instrumentPart0aMaxIndex)
        )
        instrumentPart0a.run(SKAction.move(to: position, duration: 0.5))
        instrumentPart0a.setScale(CGFloat(instrumentPart0aScale ?? 0))
        
        //Drums
        position = CGPoint(
            x: self.instrumentXs[1],
            y: maxIndexToY(maxIndex: instrumentPart1aMaxIndex)
        )
        instrumentPart1a.run(SKAction.move(to: position, duration: 0.5))
        instrumentPart1a.setScale(CGFloat(instrumentPart1aScale ?? 0))
        
        //Basslin
        position = CGPoint(
            x: self.instrumentXs[2],
            y: maxIndexToY(maxIndex: instrumentPart2aMaxIndex)
        )
        instrumentPart2a.run(SKAction.move(to: position, duration: 0.5))
        instrumentPart2a.setScale(CGFloat(instrumentPart2aScale ?? 0))
        
        //Synth
        position = CGPoint(
            x: self.instrumentXs[3],
            y: maxIndexToY(maxIndex: instrumentPart3aMaxIndex)
        )
        instrumentPart3a.run(SKAction.move(to: position, duration: 0.5))
        instrumentPart3a.setScale(CGFloat(instrumentPart3aScale ?? 0))
    }
    
    //Make box on tap, first part of this tutorial
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        let randomInt = Int.random(in: 10...75)
        
        let box = SKSpriteNode(color: .green, size: CGSize(width: randomInt, height: randomInt))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: randomInt, height: randomInt))
        box.physicsBody?.restitution = CGFloat(Float.random(in: 0.2...0.8))
        addChild(box)
    }
    
    
    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
    }
    
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
