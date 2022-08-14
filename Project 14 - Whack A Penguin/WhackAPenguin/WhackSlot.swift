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
    
    private(set) var hitToWhichCharType: CharType?
    
    enum CharType {
        case charGood
        case charEvil
    }
    
    var hole: SKSpriteNode!
    
    func config(at: CGPoint) {
        position = at
        
        hole = SKSpriteNode(imageNamed: "whackHole")
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
        
        penguin.xScale = 1
        penguin.xScale = 1
        
        if let mudEffect = SKEmitterNode(fileNamed: "mud") {
            mudEffect.position = hole.position
            mudEffect.zPosition = 2
            addChild(mudEffect)
        }
        
        if Int.random(in: 0..<2) == 0 {
            penguin.texture = SKTexture(imageNamed: "penguinGood")
            penguin.name = "charGood"
        } else {
            penguin.texture = SKTexture(imageNamed: "penguinEvil")
            penguin.name = "charEvil"
        }
        
        penguin.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))

        isVisible = true
        isHit = false
        hitToWhichCharType = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime*3.5)) { [weak self] in
            self?.hide()
        }
    }
    
    func hide(byWhacked: Bool = false) {
        if byWhacked || isVisible {
            if let sparkEffect = SKEmitterNode(fileNamed: "spark") {
                sparkEffect.position = hole.position
                sparkEffect.zPosition = 2
                addChild(sparkEffect)
            }
            
            penguin.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
            
            isVisible = false
        }
    }
    
    func hit(next doNext: @escaping (WhackSlot) -> Void) {
        guard
            isVisible,
            !isHit
        else {
            return
        }

        isHit = true
        
        let wait = SKAction.wait(forDuration: 0.25)
        let hitEffect = SKAction.run { [weak penguin, weak self] in
            if penguin?.name == "charEvil" {
                penguin?.xScale = 0.85
                penguin?.xScale = 0.85
    
                penguin?.run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
    
                self?.hitToWhichCharType = .charEvil
            } else {
                penguin?.run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
    
                self?.hitToWhichCharType = .charGood
            }
            
            if let smokeEffect = SKEmitterNode(fileNamed: "smoke") {
                smokeEffect.position = self?.hole.position ?? CGPoint()
                smokeEffect.zPosition = 2
                self?.addChild(smokeEffect)
            }
            
        }
        let notVisible = SKAction.run { [weak self] in
            self?.hide(byWhacked: true)
        }
        let callNext = SKAction.run {
            doNext(self)
        }
        
        penguin.run(SKAction.sequence([wait, hitEffect, notVisible, callNext]))

    }
}
