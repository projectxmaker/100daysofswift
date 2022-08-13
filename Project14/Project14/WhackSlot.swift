//
//  WhackSlot.swift
//  Project14
//
//  Created by Pham Anh Tuan on 8/13/22.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    var isVisible = false
    var isHit = false
    
    var penguin: SKSpriteNode!
    
    func config(at: CGPoint) {
        position = at
        
        let hole = SKSpriteNode(imageNamed: "whackHole")
        addChild(hole)
        
        let mask = SKCropNode()
        mask.zPosition = 1
        mask.position = CGPoint(x: 0, y: 10)
        mask.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        penguin = SKSpriteNode(imageNamed: "penguinGood")
        penguin.position = CGPoint(x: 0, y: -90)
        
        mask.addChild(penguin)
        
        addChild(mask)
    }
    
    func show(hideTime: Double) {
        guard !isVisible else { return }
        
        penguin.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        
        if Int.random(in: 0..<2) == 0 {
            penguin.texture = SKTexture(imageNamed: "penguinGood")
            penguin.name = "penguinGood"
        } else {
            penguin.texture = SKTexture(imageNamed: "penguinEvil")
            penguin.name = "penguinEvil"
        }

        isVisible = true
        isHit = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime*3.5)) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        guard isVisible else { return }
        
        penguin.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        
        isVisible = false
        isHit = false
    }
}
