//
//  GameScene.swift
//  Project11
//
//  Created by Pham Anh Tuan on 8/8/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var colors: [UIColor] = [UIColor.red, UIColor.blue, UIColor.yellow, UIColor.white, UIColor.purple]
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            colors.shuffle()
            let selectedColor = colors[0]
            
            let location = touch.location(in: self)
            let box = SKSpriteNode(color: selectedColor, size: CGSize(width: 64, height: 64))
            box.position = location
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
            addChild(box)
        }
    }
}
