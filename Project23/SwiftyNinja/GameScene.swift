//
//  GameScene.swift
//  Project23
//
//  Created by Pham Anh Tuan on 8/30/22.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {

    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }

    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    
    var isSwooshSoundActive = false
    
    var bombSoundEffect: AVAudioPlayer?
    
    var activeEnemies = [SKSpriteNode]()
    
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
    
    let enemyTypeRandomFrom = 0
    let enemyTypeRandomTo = 6
    let bombFusePositionX = 76
    let bombFusePositionY = 64
    let enemyPositionXRandomFrom = 64
    let enemyPositionXRandomTo = 960
    let enemyPositionY = -128
    let enemySpinningSpeedRandomFrom: CGFloat = -3
    let enemySpinningSpeedRandomTo: CGFloat = 3
    let enemyPositionXLevels: [CGFloat] = [256, 512, 768]
    let enemySpeedXAxisRandomByPositionLevel: [CGFloat: [String: Int]] = [
        256: ["from": 8, "to": 15],
        512: ["from": 3, "to": 5],
        768: ["from": 3, "to": 5]
    ]
    
    let enemySpeedXAxisRandomByPositionDefaultValueFrom = 3
    let enemySpeedXAxisRandomByPositionDefaultValueTo = 15
    
    let enemySpeedYAxisRandomFrom = 24
    let enemySpeedYAxisRandomTo = 32

    let enemySpaceshipSpeedYAxisFrom = 30
    let enemySpaceshipSpeedYAxisTo = 38
    
    let physicBodyCircleRadius: CGFloat = 64
    
    let enemyNotCollideEachOthers:UInt32 = 0
    
    var gameOver: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        createScore()
        createLives()
        createSlices()
        
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        // 1
        activeSlicePoints.removeAll(keepingCapacity: true)

        // 2
        let location = touch.location(in: self)
        activeSlicePoints.append(location)

        // 3
        redrawActiveSlice()

        // 4
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()

        // 5
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
        
        let nodes = nodes(at: location)
        for eachNode in nodes {
            if eachNode.name == "restartButton" {
                restartGame()
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameEnded {
            return
        }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        sliceToWin(location: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameEnded {
            return
        }
        
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()

                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()

                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" || node.name == "spaceship" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }

                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0

        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }

        if bombCount == 0 {
            // no bombs – stop the fuse sound!
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    // MARK: - Extra Funcs
    func startGame() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85

        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]

        for _ in 0 ... 1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    func sliceToWin(location: CGPoint) {
        let nodesAtPoint = nodes(at: location)

        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" {
                destroyPenguin(node)
            } else if node.name == "bomb" {
                destroyBomb(node)
            } else if node.name == "spaceship" {
                destroySpaceship(node)
            }
        }
    }
    
    func destroyEnemy(_ node: SKSpriteNode) {
        // 1
        if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
            emitter.position = node.position
            addChild(emitter)
        }

        // 2
        node.name = ""

        // 3
        node.physicsBody?.isDynamic = false

        // 4
        let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])

        // 5
        let seq = SKAction.sequence([group, .removeFromParent()])
        node.run(seq)
        
        // 6: update score, depending on what kind of enemy

        // 7
        if let index = activeEnemies.firstIndex(of: node) {
            activeEnemies.remove(at: index)
        }

        // 8
        run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
    }
    
    func destroySpaceship(_ node: SKSpriteNode) {
        destroyEnemy(node)

        score += 5
    }
    
    func destroyPenguin(_ node: SKSpriteNode) {
        destroyEnemy(node)

        score += 1
    }
    
    func destroyBomb(_ node: SKSpriteNode) {
        guard let bombContainer = node.parent as? SKSpriteNode else { return }

        if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
            emitter.position = bombContainer.position
            addChild(emitter)
        }

        node.name = ""
        bombContainer.physicsBody?.isDynamic = false

        let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])

        let seq = SKAction.sequence([group, .removeFromParent()])
        bombContainer.run(seq)

        if let index = activeEnemies.firstIndex(of: bombContainer) {
            activeEnemies.remove(at: index)
        }

        run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
        endGame(triggeredByBomb: true)
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)

        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }

    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)

            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2

        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3

        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9

        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5

        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    func redrawActiveSlice() {
        // 1
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }

        // 2
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }

        // 3
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])

        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }

        // 4
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true

        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"

        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)

        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode

        var enemyType = Int.random(in: enemyTypeRandomFrom...enemyTypeRandomTo)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }

        if enemyType == 0 {
            // bomb code goes here
            enemy = createBomb()
        } else if enemyType == 2 {
            enemy = createSpaceship()
        } else {
            enemy = createPenguin()
        }

        // position code goes here
        setPhysicBodyForEnemy(enemy, type: enemyType)

        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func createSpaceship() -> SKSpriteNode {
        let enemy = SKSpriteNode(imageNamed: "spaceship")
        run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
        
        enemy.name = "spaceship"
        
        return enemy
    }
    
    func createPenguin() -> SKSpriteNode {
        let enemy = SKSpriteNode(imageNamed: "penguin")
        run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
        enemy.name = "enemy"
        
        return enemy
    }
    
    func createBomb() -> SKSpriteNode {
        // 1
        let enemy = SKSpriteNode()
        enemy.zPosition = 1
        enemy.name = "bombContainer"

        // 2
        let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
        bombImage.name = "bomb"
        enemy.addChild(bombImage)

        // 3
        if bombSoundEffect != nil {
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }

        // 4
        if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
            if let sound = try?  AVAudioPlayer(contentsOf: path) {
                bombSoundEffect = sound
                sound.play()
            }
        }

        // 5
        if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
            emitter.position = CGPoint(x: bombFusePositionX, y: bombFusePositionY)
            enemy.addChild(emitter)
        }
        
        return enemy
    }
    
    func generateRandomXVelocity(positionX: CGFloat) -> Int {
        let enemyPositionXLevel = positionX
        let randomXSpeedByPosition = enemySpeedXAxisRandomByPositionLevel[enemyPositionXLevel]
        guard
            let tmpRandom = randomXSpeedByPosition,
            let from = tmpRandom["from"],
            let to = tmpRandom["to"]
        else {
            return Int.random(in: enemySpeedXAxisRandomByPositionDefaultValueFrom...enemySpeedXAxisRandomByPositionDefaultValueTo)
        }

        return Int.random(in: from...to)
    }
    
    func setPhysicBodyForEnemy(_ enemy: SKSpriteNode, type: Int) {
        // 1
        let randomPosition = CGPoint(x: Int.random(in: enemyPositionXRandomFrom...enemyPositionXRandomTo), y: enemyPositionY)
        enemy.position = randomPosition

        // 2
        let randomAngularVelocity = CGFloat.random(in: enemySpinningSpeedRandomFrom...enemySpinningSpeedRandomTo)
        let randomXVelocity: Int

        // 3
        if randomPosition.x < enemyPositionXLevels[0] {
            randomXVelocity = generateRandomXVelocity(positionX: enemyPositionXLevels[0])
        } else if randomPosition.x < enemyPositionXLevels[1] {
            randomXVelocity = generateRandomXVelocity(positionX: enemyPositionXLevels[1])
        } else if randomPosition.x < enemyPositionXLevels[2] {
            randomXVelocity = 0 - generateRandomXVelocity(positionX: enemyPositionXLevels[2])
        } else {
            randomXVelocity = 0 - generateRandomXVelocity(positionX: enemyPositionXLevels[0])
        }

        // 4
        var randomYVelocity = Int.random(in: enemySpeedYAxisRandomFrom...enemySpeedYAxisRandomTo)
        if type == 2 {
            // if enemy is a spaceship
            randomYVelocity = Int.random(in: enemySpaceshipSpeedYAxisFrom...enemySpaceshipSpeedYAxisTo)
        }

        // 5
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: physicBodyCircleRadius)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = enemyNotCollideEachOthers
    }
    
    func tossEnemies() {
        if isGameEnded {
            return
        }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02

        let sequenceType = sequence[sequencePosition]

        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)

        case .one:
            createEnemy()

        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)

        case .two:
            createEnemy()
            createEnemy()

        case .three:
            createEnemy()
            createEnemy()
            createEnemy()

        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()

        case .chain:
            createEnemy()

            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }

        case .fastChain:
            createEnemy()

            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
        }

        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    func subtractLife() {
        lives -= 1

        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))

        var life: SKSpriteNode

        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }

        life.texture = SKTexture(imageNamed: "sliceLifeGone")

        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration:0.1))
    }
    
    func endGame(triggeredByBomb: Bool) {
        if isGameEnded {
            return
        }

        isGameEnded = true
        physicsWorld.speed = 0

        bombSoundEffect?.stop()
        bombSoundEffect = nil

        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        showGameover()
    }
    
    func showGameover() {
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 420)
        gameOver.zPosition = 1
        
        let scoreNote = SKLabelNode(fontNamed: "Chalkduster")
        scoreNote.fontSize = 40
        scoreNote.text = "Final Score: \(score)"
        scoreNote.position = CGPoint(x: 0, y: -100)
        scoreNote.horizontalAlignmentMode = .center
        gameOver.addChild(scoreNote)
        
        let restartLabel = SKLabelNode()
        restartLabel.fontSize = 40
        restartLabel.text = "Restart"
        restartLabel.position = CGPoint(x: 0, y: -200)
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.name = "restartButton"
        gameOver.addChild(restartLabel)
        
        addChild(gameOver)
    }
    
    private func restartGame() {
        gameOver.removeAllChildren()
        gameOver.removeFromParent()
        
        for node in activeEnemies {
            node.removeFromParent()
        }
        activeEnemies.removeAll(keepingCapacity: true)
        
        popupTime = 0.9
        chainDelay = 3.0
        sequencePosition = 0

        isGameEnded = false
        score = 0
        lives = 3
        
        livesImages[0].texture = SKTexture(imageNamed: "sliceLife")
        livesImages[1].texture = SKTexture(imageNamed: "sliceLife")
        livesImages[2].texture = SKTexture(imageNamed: "sliceLife")
        
        startGame()
    }
}

