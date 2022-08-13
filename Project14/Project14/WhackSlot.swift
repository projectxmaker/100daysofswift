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
            penguin.name = "charGood"
        } else {
            penguin.texture = SKTexture(imageNamed: "penguinEvil")
            penguin.name = "charEvil"
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
        
        penguin.xScale = 1
        penguin.xScale = 1
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
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.05)
        let hitEffect = SKAction.run { [weak penguin, weak self] in
            if penguin?.name == "charEvil" {
                penguin?.xScale = 0.8
                penguin?.xScale = 0.8
    
                penguin?.run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
    
                self?.hitToWhichCharType = .charEvil
            } else {
                penguin?.run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
    
                self?.hitToWhichCharType = .charGood
            }
        }
        let notVisible = SKAction.run { [weak self] in
            self?.hide()
        }
        let callNext = SKAction.run { [doNext] in
            doNext(self)
        }
        
        penguin.run(SKAction.sequence([wait, hide, hitEffect, notVisible, callNext]))

    }
}
