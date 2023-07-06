//
//  WarpHoleView.swift
//  WarpHole
//
//  Created by Frans-Jan Wind on 05/07/2023.
//

import SpriteKit
import SwiftUI
import Combine

let rotationSpeedSubject = PassthroughSubject<Double, Never>()

struct WarpHoleView: UIViewRepresentable {
    
    class Coordinator {
        var scene: RotatingScene
        var cancellable: AnyCancellable?
        
        init(scene: RotatingScene) {
            self.scene = scene
            self.cancellable = rotationSpeedSubject.sink { [weak self] in
                self?.scene.rotationSpeed = $0
            }
        }
        
        deinit {
            cancellable?.cancel()
        }
    }

    class RotatingScene: SKScene {
        var spriteNode: SKSpriteNode?
        var particleNode: SKEmitterNode?
        var rotationSpeed: Double = 0.0
        var time: TimeInterval = 0.0
        
        override func didMove(to view: SKView) {
            backgroundColor = .black
            
            spriteNode = SKSpriteNode(imageNamed: "warp")
            spriteNode?.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(spriteNode!)
            
            particleNode = SKEmitterNode()
            particleNode?.particleTexture = SKTexture(imageNamed: "particle")
            particleNode?.particleBirthRate = 10
            particleNode?.particleLifetime = 10
            particleNode?.particlePositionRange = CGVector(dx: 5, dy: 5)
            particleNode?.particleSpeed = 50
            particleNode?.position = spriteNode!.position
            addChild(particleNode!)
        }
        
        override func update(_ currentTime: TimeInterval) {
            if time == 0.0 {
                time = currentTime
            }
            
            spriteNode?.zRotation -= CGFloat((rotationSpeed+0.2) * 6.28 * 1.2) / 60.0
            
            let scalingFactor = CGFloat(max(min(rotationSpeed * 0.5, 0.5), 0.01))
            spriteNode?.setScale(scalingFactor)
            spriteNode?.alpha = CGFloat(min(rotationSpeed * 10, 1.0))
            
            particleNode?.position = spriteNode!.position
            let timePassed = CGFloat(currentTime - time)
            particleNode?.emissionAngle = timePassed
            
            let particleScalingFactor = CGFloat(max(rotationSpeed * 2, 0.01))
            particleNode?.particleScale = particleScalingFactor
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scene: RotatingScene(size: CGSize(width: 800, height: 400)))
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: UIScreen.main.bounds)
        view.presentScene(context.coordinator.scene)
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) { }
}

