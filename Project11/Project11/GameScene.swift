//
//  GameScene.swift
//  Project11
//
//  Created by Pham Anh Tuan on 8/8/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        physicsWorld.contactDelegate = self
        
        let bouncerPositions = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 256, y: 0),
            CGPoint(x: 512, y: 0),
            CGPoint(x: 768, y: 0),
            CGPoint(x: 1024, y: 0)
        ]
        
        for eachPosition in bouncerPositions {
            makeBouncer(at: eachPosition)
        }
        
        struct Slot {
            var position: CGPoint
            var isGood: Bool
        }
        
        let slotPositions: [Slot] = [
            Slot(position: CGPoint(x: 128, y: 0), isGood: true),
            Slot(position: CGPoint(x: 384, y: 0), isGood: false),
            Slot(position: CGPoint(x: 640, y: 0), isGood: true),
            Slot(position: CGPoint(x: 896, y: 0), isGood: false)
        ]
        
        for eachSlot in slotPositions {
            makeSlots(at: eachSlot.position, isGood: eachSlot.isGood)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let ball = SKSpriteNode(imageNamed: "ballRed")
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2.0)
            ball.physicsBody?.restitution = 0.4
            
            guard
                let contactAllCategories = ball.physicsBody?.collisionBitMask
            else {
                return
            }
            
            ball.physicsBody?.contactTestBitMask = contactAllCategories
            
            ball.position = location
            ball.name = "ball"

            addChild(ball)
        }
    }
    
    // MARK: - Physics Contact Delegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard
            let objectA = contact.bodyA.node,
            let objectB = contact.bodyB.node
        else {
            return
        }
        
        if objectA.name == "ball" {
            collisionBetween(ball: objectA, object: objectB)
        } else if objectB.name == "ball" {
            collisionBetween(ball: objectB, object: objectA)
        }
    }
    
    private func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "bad" || object.name == "good" {
            destroyBall(ball)
        }
    }
    
    private func destroyBall(_ ball: SKNode) {
        ball.removeFromParent()
    }
    
    private func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    private func makeSlots(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        slotBase.position = position
        slotGlow.position = position
        
        let action = SKAction.rotate(byAngle: .pi, duration: 10)
        let repeatAction = SKAction.repeatForever(action)
        slotGlow.run(repeatAction)
        
        addChild(slotBase)
        addChild(slotGlow)
    }
}
