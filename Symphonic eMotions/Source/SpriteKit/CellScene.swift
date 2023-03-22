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

class Tiles: SKNode { }

class Tile: SKShapeNode { }

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
 √ Background voor actieve cellen
 √ - background strokes
 - Adaptive colors from settings
 - - Negative instrument active stroke activator
 - - Stroke invisible on connectd cell
 - Waarom heeft Upbeat Acid gespiegelde X-as
 -
 
 */

class CellScene: SKScene {
    
    //Show big ass numbers on grid positions
    var debugNumbers: Bool = false
    
    var isPlaying: Bool = false
    var currentLevel: Double = 0
    var levels: [[Int]] = []
    
    //We need to combine instrument vars in a object (SKNode?)
//    var receiver: [Receiver] = []
    
    //Skip frames for ease on particle emitter spawn
    var updateLimiter: [Int]!
    
    //GameScene globals to change through update
    //At this moment static 4 instruments
    var tiles0: Tiles!
    var instrumentPart0a: Container!
    var instrumentPart0aScale: CGFloat?
    var instrumentPart0aMaxIndex: Int = 0
    var instrumentPart0aMidiClip: Int = 0
    var instrument0Positions: [CGPoint] = []
    var instrument0Sizes: [CGSize] = []
    //TODO: Convert to Receiver Class (SKNode?) for dynamic number of instruments
    var tiles1: Tiles!
    var instrumentPart1a: Container!
    var instrumentPart1aScale: CGFloat?
    var instrumentPart1aMaxIndex: Int = 0
    var instrumentPart1aMidiClip: Int = 0
    var instrument1Positions: [CGPoint] = []
    var instrument1Sizes: [CGSize] = []
    
    var tiles2: Tiles!
    var instrumentPart2a: Container!
    var instrumentPart2aScale: CGFloat?
    var instrumentPart2aMaxIndex: Int = 0
    var instrumentPart2aMidiClip: Int = 0
    var instrument2Positions: [CGPoint] = []
    var instrument2Sizes: [CGSize] = []
    
    var tiles3: Tiles!
    var instrumentPart3a: Container!
    var instrumentPart3aScale: CGFloat?
    var instrumentPart3aMaxIndex: Int = 0
    var instrumentPart3aMidiClip: Int = 0
    var instrument3Positions: [CGPoint] = []
    var instrument3Sizes: [CGSize] = []
    
    var sessionSkin: InstrumentsSet.Skin!
    
    var columns: Int = 0
    var rows: Int = 0
    
    //Collect all areas of interest from the instrument settings
    var instrumentPartAreas: [[[Int]]] = []
    
    //MARK: Initialisation
    //Start of Scene funciton
    override func didMove(to view: SKView) {
        
        //At this stage there is a maximum of 4 instruments
        for index in [0,1,2,3] {
            
            if index == 0 {
                instrumentPart0a = setupInstrument(instrumentIndex: index)
                addChild(instrumentPart0a)
                tiles0 = setUpBackgrounds(instrumentIndex: index)
                addChild(tiles0)
            }
            else if index == 1 {
                instrumentPart1a = setupInstrument(instrumentIndex: index)
                addChild(instrumentPart1a)
                tiles1 = setUpBackgrounds(instrumentIndex: index)
                addChild(tiles1)
            }
            else if index == 2 {
                instrumentPart2a = setupInstrument(instrumentIndex: index)
                addChild(instrumentPart2a)
                tiles2 = setUpBackgrounds(instrumentIndex: index)
                addChild(tiles2)
            }
            else if index == 3 {
                instrumentPart3a = setupInstrument(instrumentIndex: index)
                addChild(instrumentPart3a)
                tiles3 = setUpBackgrounds(instrumentIndex: index)
                addChild(tiles3)
            }
        }

        if debugNumbers {
            let cell = DebugCell(columns: columns, rows: rows)
            debugGrid(cell: cell)
        }
        
        physicsBody = SKPhysicsBody()
    }
    
    //MARK: Setup Background
    func setUpBackgrounds(instrumentIndex: Int) -> Tiles {
        
        let skin = self.sessionSkin.instruments[instrumentIndex]
        let cr: CGFloat = 5
        let tiles: Tiles = Tiles()
        
        if instrumentIndex == 0 {
            for (index,position) in self.instrument0Positions.enumerated() {
                let tile = Tile(rectOf: self.instrument0Sizes[index], cornerRadius: cr)
                tiles.addChild(setBackground(skin: skin, background: tile, position: position))
            }
        }
        else if instrumentIndex == 1 {
            for (index,position) in self.instrument1Positions.enumerated() {
                let tile = Tile(rectOf: self.instrument1Sizes[index], cornerRadius: cr)
                tiles.addChild(setBackground(skin: skin, background: tile, position: position))
            }
        }
        else if instrumentIndex == 2 {
            for (index,position) in self.instrument2Positions.enumerated() {
                let tile = Tile(rectOf: self.instrument2Sizes[index], cornerRadius: cr)
                tiles.addChild(setBackground(skin: skin, background: tile, position: position))
            }
        }
        else if instrumentIndex == 3 {
            for (index,position) in self.instrument3Positions.enumerated() {
                let tile = Tile(rectOf: self.instrument3Sizes[index], cornerRadius: cr)
                tiles.addChild(setBackground(skin: skin, background: tile, position: position))
            }
        }
        return tiles
    }
    
    func setBackground(
        skin: InstrumentsSet.Skin.Instrument,
        background: Tile,
        position: CGPoint
    ) -> Tile{
        
        background.name = "tile"
        background.position = position
        background.setScale(0.89)
        background.lineWidth = 4
//        background.strokeColor = UIColor.clear
        background.strokeColor = skin.color.withAlphaComponent(0.3)
        background.fillColor = skin.color.withAlphaComponent(0.12)
        
        return background
    }
    
    //MARK: Setup instrument
    func setupInstrument(instrumentIndex: Int) -> Container{
        
        updateLimiter[instrumentIndex] = 0
        
        let skin = self.sessionSkin.instruments[instrumentIndex]
        
        let container = Container()
        
        if instrumentIndex == 0 {
            container.position = self.instrument0Positions.first ?? CGPoint()
        }
        else if instrumentIndex == 1 {
            container.position = self.instrument1Positions.first ?? CGPoint()
        }
        else if instrumentIndex == 2 {
            container.position = self.instrument2Positions.first ?? CGPoint()
        }
        else if instrumentIndex == 3 {
            container.position = self.instrument3Positions.first ?? CGPoint()
        }
        
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
    
    //MARK: The Update on frame rate function!
    override func update(_ currentTime: TimeInterval) {
        
        var instrumentIndex: Int!
        var partScale: Double!
        var position: CGPoint!
        
        updateBackgrounds()
        
        instrumentIndex = 0
        if self.instrument0Positions.indices.contains(instrumentPart0aMaxIndex){
            //First configured instrument
            position = self.instrument0Positions[instrumentPart0aMaxIndex]
            partScale = instrumentPart0aScale ?? 0
            if !self.isPlaying { partScale = 0 }
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
        if self.instrument1Positions.indices.contains(instrumentPart1aMaxIndex){
            //Second configured instrument
            position = self.instrument1Positions[instrumentPart1aMaxIndex]
            partScale = instrumentPart1aScale ?? 0
            if !self.isPlaying { partScale = 0 }
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
        if self.instrument2Positions.indices.contains(instrumentPart2aMaxIndex){
            //This needs to be an object containing excact the amount of instruments
            position = self.instrument2Positions[instrumentPart2aMaxIndex]
            partScale = instrumentPart2aScale ?? 0
            if !self.isPlaying { partScale = 0 }
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
        if self.instrument3Positions.indices.contains(instrumentPart3aMaxIndex){
            
            position = self.instrument3Positions[instrumentPart3aMaxIndex]
            partScale = instrumentPart3aScale ?? 0
            if !self.isPlaying { partScale = 0 }
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
    
    //MARK: Update background
    //TODO: Add stroke opacity controller
    func updateBackgrounds(){
        
        //TODO: Do this on level change so update can be used for further increase alpha
        var partScale: Double!
        
        //First itteration for not showing if not in current level
        for (index, trackLevels) in levels.enumerated() {
            let skin = self.sessionSkin.instruments[index]
            if index == 0 {
                if trackLevels.contains(Int(currentLevel)) {
                    partScale = self.instrumentPart0aScale ?? 0
                    if !self.isPlaying { partScale = 0 }
                    tiles0.enumerateChildNodes(withName: "tile") { node, _ in
                        node.alpha = 1
                        if let shapeNode = node as? SKShapeNode {
                            shapeNode.strokeColor = skin.color.withAlphaComponent(partScale*partScale*0.8)
                        }
                    }
                }
                else{
                    tiles0.enumerateChildNodes(withName: "tile") { node, _ in
                        node.alpha = 0
                    }
                }
            }
            if index == 1 {
                if trackLevels.contains(Int(currentLevel)) {
                    partScale = self.instrumentPart1aScale ?? 0
                    if !self.isPlaying { partScale = 0 }
                    tiles1.enumerateChildNodes(withName: "tile") { node, _ in
                        node.alpha = 1
                        if let shapeNode = node as? SKShapeNode {
                            shapeNode.strokeColor = skin.color.withAlphaComponent(partScale*partScale*0.8)
                        }
                    }
                }
                else{
                    tiles1.enumerateChildNodes(withName: "tile") { node, _ in
                        node.alpha = 0
                    }
                }
            }
            if index == 2 {
                if trackLevels.contains(Int(currentLevel)) {
                    partScale = self.instrumentPart2aScale ?? 0
                    if !self.isPlaying { partScale = 0 }
                    tiles2.enumerateChildNodes(withName: "tile") { node, _ in
                        node.alpha = 1
                        if let shapeNode = node as? SKShapeNode {
                            shapeNode.strokeColor = skin.color.withAlphaComponent(partScale*partScale*0.8)
                        }
                    }
                }
                else{
                    tiles2.enumerateChildNodes(withName: "tile") { node, _ in
                        node.alpha = 0
                    }
                }
            }
            if index == 3 {
                if trackLevels.contains(Int(currentLevel)) {
                    partScale = self.instrumentPart3aScale ?? 0
                    if !self.isPlaying { partScale = 0 }
                    tiles3.enumerateChildNodes(withName: "tile") { node, _ in
                        node.alpha = 1
                        if let shapeNode = node as? SKShapeNode {
                            shapeNode.strokeColor = skin.color.withAlphaComponent(partScale*partScale*0.8)
                        }
                    }
                }
                else{
                    tiles3.enumerateChildNodes(withName: "tile") { node, _ in
                        node.alpha = 0
                    }
                }
            }
        }
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
        let ranges: [Int] = [100,50,25,12]
        if ranges.indices.contains(midiClip) {
            return ranges[midiClip]
        }
        else { return 0 }
    }
    
    
    func reverseNumber(number:Int, min:Int, max:Int) -> Int{
        return (max + min) - number
    }
    
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
