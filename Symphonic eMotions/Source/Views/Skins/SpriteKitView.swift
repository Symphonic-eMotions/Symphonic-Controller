//
//  SpriteKitView.swift
//  Symphonic eMotions Pro RC
//
//  Created by Frans-Jan Wind on 31/01/2023.
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
    let areas:[[Int]]
}

class GameScene: SKScene {
    
//    @ObservedObject var viewModel: MainViewModel
    
    //Columns
    let columns = 3
    //Rows
    let rows = 2
    
    let instrument1 = CellInstrument(
        color: UIColor(red: 151/255, green: 71/255, blue: 255/255, alpha: 1),
        shape: "Circle",
        image: "Instrument Piano Keys",
        areas:[
            [1,0,0,0,
             1,0,0,0],
            [1,0,0,0,
             0,0,0,0]
        ]
    )
    
    override func didMove(to view: SKView) {
        
        let instrument = instrument1
        let cell = Cell(columns: columns, rows: rows)
        
        setupGridAndInstruments(cell: cell, instrument: instrument)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    func setupGridAndInstruments(cell: Cell, instrument: CellInstrument) {
        
        var index:Int = 0
        let localSize:CGFloat = 100
        
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
                
                //For now only first oart is read
                if instrument.areas[0][index] == 1 {

//                    let instrumentPart = SKShapeNode(circleOfRadius: CGFloat(localSize))
//                    let ipSize = CGSize(width: localSize, height: localSize)
                    //SKSpriteNode offers higher performance than SKShapeNode class
                    let instrumentPart = SKShapeNode(circleOfRadius: localSize)
                    instrumentPart.position = CGPoint(x: size.width * xOffset, y: size.height * yOffset)
                    instrumentPart.fillColor = SKColor.clear
                    instrumentPart.strokeColor = instrument.color
                    
                    
                    instrumentPart.physicsBody = SKPhysicsBody(circleOfRadius: localSize)
                    instrumentPart.physicsBody?.affectedByGravity = false
                    instrumentPart.physicsBody?.pinned = true
                    addChild(instrumentPart)
                }
                
//                if instrumentPart[index] == 1 {
//                    //Placing an image
//                    let image = SKSpriteNode(imageNamed: "Circle")
//                    image.scale(to: CGSize(width: localSize, height: localSize))
//                    image.position = CGPoint(x: size.width * xOffset, y: size.height * yOffset)
//                    addChild(image)
//                }
                
    
                let indexText = SKLabelNode(fontNamed: "Arial")
                indexText.text = "\(index)"
                indexText.fontSize = 50
                indexText.fontColor = SKColor.green
                indexText.position = CGPoint(x: size.width * xOffset, y: size.height * yOffsetText)
                
                addChild(indexText)
            
                index += 1
                
//                return container
            }
        }
    }
    
    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
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
    
    override func update(_ currentTime: TimeInterval) {
        
//        print("called on: \(currentTime)")
        
    }
}

// A sample SwiftUI creating a GameScene and sizing it
// at 300x400 points
struct SpriteKitView: View {
    
    let transportHeigth: CGFloat = 100
    
    var scene: SKScene {
        
        let scene = GameScene()
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        scene.size = CGSize(width: width, height: height)
        scene.scaleMode = .fill
//        scene.viewModel = self.viewModel
        
//        scene.size = CGSize(width: 300, height: 400)
//        scene.scaleMode = .fill
        
        return scene
    }

    var body: some View {
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        ZStack(alignment: .top) {
            
            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(width: width, height: height)
                .ignoresSafeArea()
            
            Text("width: \(width) height: \(height)")
                .font(.headline).fontWeight(.bold)
                .padding().cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1.0))
            
            
        }
    }
}
