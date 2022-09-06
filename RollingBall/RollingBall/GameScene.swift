//
//  GameScene.swift
//  RollingBall
//
//  Created by Pham Anh Tuan on 9/5/22.
//

import CoreMotion
import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene {
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!

    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var levelLabel: SKLabelNode!
    var currentLevel: Int = 0 {
        didSet {
            levelLabel.text = "Level: \(currentLevel)"
        }
    }
    
    var collideToVortex = false
    
    var gameScore: SKLabelNode!
    
    var gameOver: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelLabel.text = "Level: 0"
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: 850, y: 16)
        levelLabel.zPosition = 2
        addChild(levelLabel)
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
        
        let nodes = nodes(at: location)
        for eachNode in nodes {
            if eachNode.name == "restartButton" {
                restartGame()
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard collideToVortex == false else { return }
        
        #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
        #endif
    }
    
    // MARK: - Extra Funcs
    func buildNodes() {
        let lines = loadLevel()
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)

                if letter == "x" {
                    // load wall
                    loadWall(position: position)
                } else if letter == "v"  {
                    // load vortex
                    loadVortex(position: position)
                } else if letter == "s"  {
                    // load star
                    loadStar(position: position)
                } else if letter == "f"  {
                    // load finish
                    loadFinish(position: position)
                } else if letter == " " {
                    // this is an empty space – do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
    func loadLevel() -> [String] {
        let fileNameParts = getLeveFileByLevel(currentLevel)
        let fileName = fileNameParts["name"] ?? ""
        let fileExtension = fileNameParts["extension"] ?? ""
        let fileFullName = "\(fileName).\(fileExtension)"
        
        guard let levelURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            fatalError("Could not find \(fileFullName) in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load \(fileFullName) from the app bundle.")
        }

        return levelString.components(separatedBy: "\n")
    }
    
    func loadWall(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        node.zPosition = 1

        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        
        addChild(node)
    }
    
    func loadVortex(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.zPosition = 1
        
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    
    func loadStar(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.position = position
        node.zPosition = 1
        
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0

        addChild(node)
    }
    
    func loadFinish(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.position = position
        node.zPosition = 1
        
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0

        addChild(node)
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5

        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    
    func hasNextLevel() -> Bool {
        let tmpNextLevel = currentLevel + 1
        let levelFileInfo = getLeveFileByLevel(tmpNextLevel)
        let fileName = levelFileInfo["name"] ?? ""
        let fileExtension = levelFileInfo["extension"] ?? ""
        
        guard let _ = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            return false
        }
        
        currentLevel = tmpNextLevel
        return true
    }
    
    func getLeveFileByLevel(_ level: Int) -> [String: String] {
        let fileName = "level\(level)"
        let fileExtension = "txt"
        
        return ["name": fileName, "extension": fileExtension]
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            collideToVortex = true
            score -= 1

            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.collideToVortex = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            startGame()
        }
    }
    
    func startGame() {
        physicsWorld.gravity = .zero
        clearPlayground()
        
        if hasNextLevel() {
            buildNodes()
            createPlayer()
        } else {
            // game is over
            showGameover()
        }
    }
    
    func clearPlayground() {
        for eachNode in children {
            if eachNode.zPosition == 1 {
                eachNode.removeFromParent()
            }
        }
    }
    
    func showGameover() {
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 420)
        gameOver.zPosition = 1
        
        let scoreNote = SKLabelNode(fontNamed: "Chalkduster")
        scoreNote.fontSize = 40
        scoreNote.text = "Final Score: \(score) at Level: \(currentLevel)"
        scoreNote.position = CGPoint(x: 0, y: -100)
        scoreNote.horizontalAlignmentMode = .center
        gameOver.addChild(scoreNote)
        
        let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.fontSize = 40
        restartLabel.text = "Restart"
        restartLabel.position = CGPoint(x: 0, y: -200)
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.name = "restartButton"
        gameOver.addChild(restartLabel)
        
        addChild(gameOver)
    }
    
    func restartGame() {
        // reset info
        score = 0
        currentLevel = 0

        collideToVortex = false
        lastTouchPosition = nil
        
        startGame()
    }
}
