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

struct CellInstrument{
    
    let color:UIColor
    let shape:String
    let image:String
    let areas:[Int]
}

class CellScene: SKScene {
    
    let debugNumbers: Bool = true
    
    //GameScene globals to change through update
    var instrumentPart0a: SKShapeNode!
    var instrumentPart0aScale: CGFloat = 0
    
    var sessionSkin: InstrumentsSet.Skin!
    
    //Columns
    let columns = 3
    //Rows
    let rows = 3
    
    //Start of Scene funciton
    override func didMove(to view: SKView) {
        
//        print(sessionSkin!)
        
//        let instrument = instrument1
        let instrument = sessionSkin.instruments[0]
        let cell = Cell(columns: columns, rows: rows)
        
        print(instrument.color)
        
        let cellInstrument = CellInstrument(
//            color: UIColor(red: 151/255, green: 71/255, blue: 255/255, alpha: 1),
            color: instrument.color,
            shape: instrument.shape.rawValue,
            image: instrument.image,
            areas: instrument.areas[0]
        )
        
        setupGrid(cell: cell, instrument: cellInstrument)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    func setupGrid(cell: Cell, instrument: CellInstrument) {
        
//        let trackNr:Int = 0
//        var partNr:Int = 0
        let localSize:CGFloat = 260
        
        var index: Int = 0
        
        for row in 0..<cell.rows {
            
            for column in 0..<cell.columns {
                
                //Calculate the horizontal center of all cells
                let xOffset = CGFloat(Float(column) * cell.celWidth + cell.centerWidth)
                
                //Calculate the vertical center of all cells
                //Reverse columns for mirrored output on x-axis (SpriteKit 0:0 is left bottom, SeM 0:0 is left top)
                let reversedColumn = reverseNumber(number: row, min: 0, max: rows - 1)
                let yOffset = CGFloat(Float(reversedColumn) * cell.celHeight + cell.centerHeigth)
                
                //For debuging we show text in all cells
                let yOffsetText = CGFloat(Float(reversedColumn) * cell.celHeight + cell.centerHeigth - 0.013)
                
                if instrument.areas[index] == 1 {
                    
                    print("SETTING UP INSTRUMENT \(localSize) \(xOffset) \(yOffset)")
                    
                    instrumentPart0a = setupInstrumentPart(localSize: localSize, xOffset: xOffset, yOffset: yOffset, color: instrument.color)
                        
                    addChild(instrumentPart0a)
                }
                
                if debugNumbers {
                    let debugNumber = setUpDebugNumbers(index: index, xOffset: xOffset, yOffsetText: yOffsetText)
                    addChild(debugNumber)
                }
                
                index += 1
            }
        }
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
    
    func setUpDebugNumbers(index:Int, xOffset: CGFloat, yOffsetText: CGFloat) -> SKLabelNode {
        
        let indexText = SKLabelNode(fontNamed: "Arial")
        indexText.text = "\(index)"
        indexText.fontSize = 50
        indexText.fontColor = SKColor.green
        indexText.alpha = 0.5
        indexText.position = CGPoint(x: size.width * xOffset, y: size.height * yOffsetText)
        
        return indexText
    }
    
    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        instrumentPart0a.setScale(CGFloat(instrumentPart0aScale))
                
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
    
    
}
