//
//  HeartEffectScene.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/19/25.
//

import Foundation
import SpriteKit

final class HeartEffectScene: SKScene {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        createNodes(for: size)
        
        scaleMode = .fill
        self.backgroundColor = .clear // make background clear... ref:
        view?.allowsTransparency = true
    }
    
    private func createNodes(for size: CGSize) {
        let xPos = size.width / 2
        let yPos = size.height * 0.9
        
        if let emitter = createParticleEmitter(position: .init(x: xPos, y: yPos)) {
            addChild(emitter)
        }
    }
    
    func createParticleEmitter(position: CGPoint) -> SKEmitterNode? {
        if let node = SKEmitterNode(fileNamed: "HeartParticle.sks") {
            node.position = position
            return node
        }
        
        return nil
    }
}
