//
//  AmoebaScene.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 26/06/2023.
//

import SpriteKit

class AmoebaScene: SKScene {
    
    let backgroundNode = SKSpriteNode(imageNamed: "demoBlob")
    
    var rotationDuration: TimeInterval = 10.0 {
        didSet {
            // Update the rotation action when the duration changes.
            self.backgroundNode.removeAllActions()
            self.backgroundNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: rotationDuration)))
        }
    }
    
//    var instrumentPart1aScale: CGFloat?
//    var instrumentPart1aMaxIndex: Int = 0
//    var instrumentPart1aMidiClip: Int = 0
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = .clear
        
        // position the sprite node to center of the screen
        // adjust the anchor point to the center
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // set the size of the sprite node to match the scene's size
        backgroundNode.size = self.size

//        let uniforms: [SKUniform] = [
//            SKUniform(name: "u_time", float: 1),
//            SKUniform(name: "u_speed", float: 1),
//            SKUniform(name: "u_strength", float: 3),
//            SKUniform(name: "u_frequency", float: 20)
//        ]
////
//        let shader = SKShader(fileNamed: "AmoebaShader")
//        shader.uniforms = uniforms
//        backgroundNode.shader = shader
        
        backgroundNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: rotationDuration)))
        
        // add the sprite node to the scene
        addChild(backgroundNode)
    }

    override func update(_ currentTime: TimeInterval) {
        let time = Float(currentTime)
        backgroundNode.shader?.uniforms[0] = SKUniform(name: "u_time", float: time)
    }
}

