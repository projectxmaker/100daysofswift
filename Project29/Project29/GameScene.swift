//
//  GameScene.swift
//  Project29
//
//  Created by Pham Anh Tuan on 9/13/22.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene {
    var buildings = [BuildingNode]()
    weak var viewController: GameViewController!
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!

    var currentPlayer = 1
    var levelWinner: SKSpriteNode?

    var gameOver: SKLabelNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)

        createBuildings()
        createPlayers()        
        
        physicsWorld.contactDelegate = self
    }

    func createBuildings() {
        var currentX: CGFloat = -15

        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2

            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)

            buildings.append(building)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let nodes = nodes(at: location)
        for eachNode in nodes {
            if eachNode.name == "restartButton" {
                restartGame()
                break
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }

        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
    // MARK: - Extra Functions
    func launch(angle: Int, velocity: Int) {
        // 1
        let speed = Double(velocity) / 10.0

        // 2
        let radians = deg2rad(degrees: angle)

        // 3
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }

        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)

        if currentPlayer == 1 {
            // 4
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20

            // 5
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)

            // 6
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            // 7
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20

            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)

            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func createPlayers() {
        let player1Name = "player1"
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = player1Name
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false

        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        let player2Name = "player2"
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = player2Name
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false

        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }

}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }

        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }

        if firstNode.name == "banana" && secondNode.name == "player1" {
            levelWinner = player2
            destroy(player: player1)
        }

        if firstNode.name == "banana" && secondNode.name == "player2" {
            levelWinner = player1
            destroy(player: player2)
        }
    }
    
    func destroy(player: SKSpriteNode) {
        guard
            let player1Name = player1.name,
            let player2Name = player2.name,
            let levelWinner = levelWinner
        else { return }
        
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }

        player.removeFromParent()
        banana.removeFromParent()
        
        updateScore(player: levelWinner)
        
        if viewController.isGameover() {
            showGameover()
        } else {
            viewController.showScore(player1Name: player1Name, player2Name: player2Name)
            
            // move to next level
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.viewController.hideScore()
                self.viewController.showPlayerNumber()
                
                self.startGame()
            }
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }

        viewController.activatePlayer(number: currentPlayer)
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)

        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }

        banana.name = ""
        banana.removeFromParent()
        banana = nil

        changePlayer()
    }
    
    func updateScore(player: SKSpriteNode) {
        guard
            let playerName = player.name
        else { return }
        
        viewController.updateScore(player: playerName)
        
        viewController.hidePlayerNumber()
    }
    
    func removeAllNodes() {
        for each in children {
            each.removeAllChildren()
            each.removeFromParent()
        }
    }
    
    func showGameover() {
        removeAllNodes()
        
        gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.fontSize = 60
        gameOver.text = "GAME OVER!"
        gameOver.horizontalAlignmentMode = .center
        gameOver.position = CGPoint(x: 512, y: 520)
        gameOver.fontColor = UIColor.yellow
        gameOver.zPosition = 1
        
        let winnderNote = SKLabelNode(fontNamed: "Chalkduster")
        winnderNote.fontSize = 40
        winnderNote.position = CGPoint(x: 0, y: -100)
        winnderNote.horizontalAlignmentMode = .center
        winnderNote.fontColor = UIColor.yellow
        
        winnderNote.text = viewController.getWinnerDescription()
        gameOver.addChild(winnderNote)
        
        let scoreNote = SKLabelNode(fontNamed: "Chalkduster")
        scoreNote.fontSize = 40
        scoreNote.position = CGPoint(x: 0, y: -200)
        scoreNote.horizontalAlignmentMode = .center
        scoreNote.fontColor = UIColor.yellow
        
        scoreNote.text = viewController.getScoreDescription(player1Name: player1.name ?? "", player2Name: player2.name ?? "")
        gameOver.addChild(scoreNote)
        
        let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.fontSize = 40
        restartLabel.text = "Restart"
        restartLabel.position = CGPoint(x: 0, y: -300)
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.name = "restartButton"
        restartLabel.fontColor = UIColor.yellow
        gameOver.addChild(restartLabel)
        
        addChild(gameOver)
    }
    
    func restartGame() {
        viewController.resetScore()
        
        startGame()
    }
    
    func startGame() {
        let newGame = GameScene(size: self.size)
        newGame.viewController = self.viewController
        self.viewController.currentGame = newGame
        self.viewController.hideScore()

        self.changePlayer()
        newGame.currentPlayer = self.currentPlayer

        let transition = SKTransition.doorway(withDuration: 1)
        self.view?.presentScene(newGame, transition: transition)
    }
    
    func initScore() {
        viewController.updateScore(player: player1.name ?? "", initScore: 0)
        viewController.updateScore(player: player2.name ?? "", initScore: 0)
    }
}
