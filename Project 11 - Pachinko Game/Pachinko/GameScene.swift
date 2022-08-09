//
//  GameScene.swift
//  Project11
//
//  Created by Pham Anh Tuan on 8/8/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var remainingBallLabel: SKLabelNode!
    let defaultTotalBall = 5
    let rewardedBallsForHittingGreenSlot = 2
    var remainingBall = 0 {
        didSet {
            remainingBallLabel.text = "Ball: \(remainingBall)"
        }
    }
    
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }
    
    private var editLabel: SKLabelNode!
    private var edittingMode = false {
        didSet {
            if edittingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
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
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 830, y: 730)
        addChild(scoreLabel)
        
        remainingBallLabel = SKLabelNode(fontNamed: "Chalkduster")
        remainingBallLabel.text = "Ball: \(defaultTotalBall)"
        remainingBallLabel.horizontalAlignmentMode = .right
        remainingBallLabel.position = CGPoint(x: 950, y: 680)
        addChild(remainingBallLabel)

        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        scoreLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 80, y: 730)
        addChild(editLabel)
        
        remainingBall = defaultTotalBall
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let tappedNodes = nodes(at: location)
            if tappedNodes.contains(editLabel) {
                edittingMode.toggle()
            } else {
                if edittingMode {
                    createObstacles(at: location)
                } else {
                    createBall(at: location)
                }
            }
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
            destroyObstacle(objectB)
        } else if objectB.name == "ball" {
            collisionBetween(ball: objectB, object: objectA)
            destroyObstacle(objectA)
        }
    }
    
    // MARK: - Extra Functions
    private func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "bad" {
            score -= 1
            destroyBall(ball)
        } else if object.name == "good" {
            score += 1
            remainingBall += rewardedBallsForHittingGreenSlot
            destroyBall(ball)
        }
    }
    
    private func destroyBall(_ ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }

        destroyNode(ball)
    }
    
    private func destroyObstacle(_ obstacle: SKNode) {
        if obstacle.name == "obstacle" {
            destroyNode(obstacle)
        }
    }
    
    private func destroyNode(_ node: SKNode) {
        node.removeFromParent()
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
    
    private func createBall(at location: CGPoint) {
        if remainingBall > 0 {
            remainingBall -= 1
            
            var ballImages = ["ballRed", "ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballYellow"]
            ballImages.shuffle()
            let randomBallImage = ballImages[0]
            
            let ball = SKSpriteNode(imageNamed: randomBallImage)
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2.0)
            ball.physicsBody?.restitution = 0.4
            
            guard
                let contactAllCategories = ball.physicsBody?.collisionBitMask
            else {
                return
            }
            
            ball.physicsBody?.contactTestBitMask = contactAllCategories
            
            let ballLocationNearTop = CGPoint(x: location.x, y: 730)
            ball.position = ballLocationNearTop
            ball.name = "ball"

            addChild(ball)
        }
    }
    
    private func createObstacles(at location: CGPoint) {
        let randomeSize = CGSize(width: Int.random(in: 16...128), height: 16)
        let randomColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
        
        let obstacle = SKSpriteNode(color: randomColor, size: randomeSize)
        
        obstacle.zRotation = CGFloat.random(in: 1...3)
        
        obstacle.name = "obstacle"
        
        obstacle.position = location
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: randomeSize)
        obstacle.physicsBody?.isDynamic = false
        
        addChild(obstacle)
    }
}
