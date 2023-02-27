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
    let color:UIColor
    let shape:String
    let image:String
//    let areas:[Int]
}

class CellScene: SKScene {
    
    var debugNumbers: Bool = true
//    var videoOpacity: Float = 0
    
    //GameScene globals to change through update
    //At this moment static 4 instruments
    var instrumentPart0a: SKShapeNode!
    var instrumentPart0aScale: CGFloat?
    var instrumentPart0aMaxIndex: Int = 0
    
    var instrumentPart1a: SKShapeNode!
    var instrumentPart1aScale: CGFloat?
    var instrumentPart1aMaxIndex: Int = 0
    
    var instrumentPart2a: SKShapeNode!
    var instrumentPart2aScale: CGFloat?
    var instrumentPart2aMaxIndex: Int = 0
    
    var instrumentPart3a: SKShapeNode!
    var instrumentPart3aScale: CGFloat?
    var instrumentPart3aMaxIndex: Int = 0
    
    var sessionSkin: InstrumentsSet.Skin!
    
    var columns: Int = 0
    var rows: Int = 0
    
    var instrumentXs: [CGFloat] = []
    var yStep: CGFloat = 0
    var rememberYs: [CGFloat] = []
    var instrumentYs: [CGFloat] = []
    
    //Collect all areas of interest from the instrument settings
    var instrumentPartAreas: [[[Int]]] = []
    
    //Start of Scene funciton
    override func didMove(to view: SKView) {
        
        //At this stage there is a maximum of 4 instruments
        for (index,_) in instrumentXs.enumerated() {
            
            if index == 0 {
                instrumentPart0a = setupInstrument(instrumentIndex: index)
                addChild(instrumentPart0a)
            }
            else if index == 1 {
                instrumentPart1a = setupInstrument(instrumentIndex: index)
                addChild(instrumentPart1a)
            }
            else if index == 2 {
                instrumentPart2a = setupInstrument(instrumentIndex: index)
                addChild(instrumentPart2a)
            }
            else if index == 3 {
                instrumentPart3a = setupInstrument(instrumentIndex: index)
                addChild(instrumentPart3a)
            }
        }
        
        if debugNumbers {
            let cell = Cell(columns: columns, rows: rows)
            debugGrid(cell: cell)
        }
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    func setupInstrument(instrumentIndex: Int) -> SKShapeNode{
        
        let skin = self.sessionSkin.instruments[instrumentIndex]
        
        let instrument = SKShapeNode(circleOfRadius: self.size.width / CGFloat(self.columns + 1))
        instrument.position = CGPoint(x: self.instrumentXs[instrumentIndex], y: self.instrumentYs[instrumentIndex])
        instrument.fillColor = skin.color
        instrument.strokeColor = skin.color
        
        return instrument
    }
    
    func maxIndexToY(maxIndex: Int) -> CGFloat {
        
        var y: CGFloat = 100
        
        y += CGFloat(maxIndex) * self.yStep
        
        return y
    }
    
    func setupInstrumentPart(localSize: CGFloat, xOffset: CGFloat, yOffset: CGFloat, color: UIColor) -> SKShapeNode{
        
        //SKSpriteNode offers higher performance than SKShapeNode class
        
        let instrumentPart = SKShapeNode(circleOfRadius: localSize)
        instrumentPart.position = CGPoint(x: size.width * xOffset, y: size.height * yOffset)
        instrumentPart.fillColor = SKColor.clear
        instrumentPart.lineWidth = 3
        instrumentPart.glowWidth = 3
        instrumentPart.strokeColor = color
        
        instrumentPart.physicsBody = SKPhysicsBody(circleOfRadius: localSize)
        instrumentPart.physicsBody?.affectedByGravity = false
        instrumentPart.physicsBody?.pinned = true
        
        //        if instrumentPart[index] == 1 {
        //            //Placing an image
        //            let image = SKSpriteNode(imageNamed: "Circle")
        //            image.scale(to: CGSize(width: localSize, height: localSize))
        //            image.position = CGPoint(x: size.width * xOffset, y: size.height * yOffset)
        //            addChild(image)
        //        }
        
        return instrumentPart
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //Show numbers if video is requested
//        self.debugNumbers = videoOpacity > 0
        
        //Cello
        instrumentPart0a.position = CGPoint(
            x: self.instrumentXs[0],
            y: maxIndexToY(maxIndex: instrumentPart0aMaxIndex)
        )
        instrumentPart0a.setScale(CGFloat(instrumentPart0aScale ?? 0))
        
        //Drums
        instrumentPart1a.position = CGPoint(
            x: self.instrumentXs[1],
            y: maxIndexToY(maxIndex: instrumentPart1aMaxIndex)
        )
        instrumentPart1a.setScale(CGFloat(instrumentPart1aScale ?? 0))
        
        //Bassline
//        print("MaxIndex Bassline: \(instrumentPart2aMaxIndex) Drums: \(instrumentPart1aMaxIndex)")
        instrumentPart2a.position = CGPoint(
            x: self.instrumentXs[2],
            //
            y: maxIndexToY(maxIndex: reverseNumber(number: instrumentPart2aMaxIndex, min: 0, max: 3))
        )
        instrumentPart2a.setScale(CGFloat(instrumentPart2aScale ?? 0))
        
        //Synth
        instrumentPart3a.position = CGPoint(
            x: self.instrumentXs[3],
            y: maxIndexToY(maxIndex: instrumentPart3aMaxIndex)
        )
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
