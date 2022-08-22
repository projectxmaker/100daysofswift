//
//  GameScene.swift
//  Project20
//
//  Created by Pham Anh Tuan on 8/22/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var background: SKSpriteNode!
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    
    var waveCounter = 0
    var limitedWaveCounter = 5

    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // MARK: - Variables for GameOver
    var isGameOver = false
    var gameOverPopup: SKSpriteNode!
    
    // MARK: - Scene Funcs
    override func didMove(to view: SKView) {
        background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 20, y: 15)
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)

    }

    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                firework.removeFromParent()
                fireworks.remove(at: index)
            }
        }
    }
    
    // MARK: - Extra Funcs
    @objc private func launchFireworks() {
        guard waveCounter < limitedWaveCounter else {
            gameOver()
            return
        }
        
        let movementAmount: CGFloat = 1800

        waveCounter += 1
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break
        }
        

    }
    
    private func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        case 2:
            firework.color = .red
        default:
            break
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        fireworks.append(node)
        addChild(node)
    }
    
    private func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        if isGameOver {
            for eachNode in nodes {
                guard let eachNodeName = eachNode.name else { continue }
                
                if eachNodeName == "restartButton" {
                    startGame()
                    break
                }
            }
        } else {
            for case let node as SKSpriteNode in nodes {
                guard node.name == "firework" else { continue }
                
                for parent in fireworks {
                    guard let firework = parent.children.first as? SKSpriteNode else { continue }
                    if firework.name == "selected" && firework.color != node.color {
                        firework.colorBlendFactor = 1
                        firework.name = "firework"
                    }
                }
                
                node.name = "selected"
                node.colorBlendFactor = 0
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            run(SKAction.sequence([
                SKAction.run { [weak self] in
                    emitter.position = firework.position
                    self?.addChild(emitter)
                },
                SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false),
                SKAction.wait(forDuration: TimeInterval(0.5)),
                SKAction.run {
                    emitter.removeFromParent()
                }
            ]))
        }

        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }

            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }

        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    func stopGametimer() {
        gameTimer?.invalidate()
    }
    
    func startGametimer() {
        stopGametimer()
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    // MARK: - GameOver Funcs
    
    private func gameOver() {
        stopGametimer()
        
        isGameOver = true
        
        for eachChild in children {
            eachChild.removeFromParent()
        }
        
        gameOverPopup = SKSpriteNode(imageNamed: "gameOver")
        gameOverPopup.position = CGPoint(x: 512, y: 450)
        gameOverPopup.zPosition = 1
        
        let scoreNote = SKLabelNode(fontNamed: "Chalkduster")
        scoreNote.fontSize = 40
        scoreNote.text = "Final Score: \(score)"
        scoreNote.position = CGPoint(x: 0, y: -100)
        scoreNote.horizontalAlignmentMode = .center
        gameOverPopup.addChild(scoreNote)
        
        let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.fontSize = 40
        restartLabel.text = "Restart"
        restartLabel.position = CGPoint(x: 0, y: -200)
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.name = "restartButton"
        gameOverPopup.addChild(restartLabel)
        
        addChild(gameOverPopup)
    }
    
    private func startGame() {
        if gameOverPopup != nil {
            gameOverPopup.removeAllChildren()
            gameOverPopup.removeFromParent()
        }
        
        isGameOver = false
        score = 0
        waveCounter = 0
        
        addChild(background)
        addChild(scoreLabel)
        
        startGametimer()
    }
}
