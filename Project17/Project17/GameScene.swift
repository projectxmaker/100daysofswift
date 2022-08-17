//
//  GameScene.swift
//  Project17
//
//  Created by Pham Anh Tuan on 8/17/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    private var startField: SKEmitterNode!
    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var possibleEnemy = ["ball", "hammer", "tv"]
    private var isGameOver = false
    private var gameTimer: Timer?
    
    private var allowToMovePlayer = false
    
    private let defaultTimerInterval: Float = 1
    private let deducedTimerIntervalEachWave: Float = 0.1
    private let maximumNumberOfEnemiesPerWave = 1
    private var currentTimerInterval: Float = 0
    private var currentNumberOfEnemiesCreatedPerWave = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        startField = SKEmitterNode(fileNamed: "starfield")
        startField.position = CGPoint(x: 1024, y: 384)
        startField.advanceSimulationTime(10)
        startField.zPosition = -1
        addChild(startField)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.name = "player"
        
        guard let playerTexture = player.texture else { return }
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        createWave()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for eachNode in nodes {
            if eachNode.name == "player" {
                allowToMovePlayer = true
                break
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        allowToMovePlayer = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if allowToMovePlayer {
            if location.y < 100 {
                location.y = 100
            } else if location.y > 668 {
                location.y = 668
            }
            
            player.position = location
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let explosion = SKEmitterNode(fileNamed: "explosion") else { return }
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
    }
    
    // MARK: - Extra Functions
    @objc private func createEnemy() {
        guard currentNumberOfEnemiesCreatedPerWave < maximumNumberOfEnemiesPerWave else {
            createWave()
            return
        }
        
        guard let enemyName = possibleEnemy.randomElement() else { return}
        
        let enemy = SKSpriteNode(imageNamed: enemyName)
        enemy.position = CGPoint(x: 2000, y: Int.random(in: 50...736))
        
        guard let enemyTexture = enemy.texture else { return }
        
        enemy.physicsBody = SKPhysicsBody(texture: enemyTexture, size: enemy.size)
        enemy.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemy.physicsBody?.categoryBitMask = 1
        enemy.physicsBody?.angularVelocity = 5
        enemy.physicsBody?.linearDamping = 0
        enemy.physicsBody?.angularDamping = 0
        addChild(enemy)
        
        currentNumberOfEnemiesCreatedPerWave += 1
        print("enemies: \(currentNumberOfEnemiesCreatedPerWave)")
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -200 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    private func createWave() {
        if currentTimerInterval == 0 {
            currentTimerInterval = defaultTimerInterval
        } else {
            currentTimerInterval -= deducedTimerIntervalEachWave
        }
        
        let timeInterval = TimeInterval(currentTimerInterval)
        
        currentNumberOfEnemiesCreatedPerWave = 0

        print("interval: \(currentTimerInterval) : \(currentTimerInterval < 0 ? "true" : "false")")
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
}
