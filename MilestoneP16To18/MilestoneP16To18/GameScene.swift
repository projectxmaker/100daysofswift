//
//  GameScene.swift
//  MilestoneP16To18
//
//  Created by Pham Anh Tuan on 8/18/22.
//

import SpriteKit
import GameplayKit

struct TimerUserInfo {
    var type: GameScene.SpeedType
    var direction: GameScene.FlowDirection
    var line: GameScene.RunningLine
}

let goodCharacter = "goodCharacter"
let badCharacter = "badCharacter"

class GameScene: SKScene {
    
    enum FlowDirection {
        case ltr
        case rtl
    }
    
    enum SpeedType {
        case fast
        case slow
    }
    
    enum RunningLine {
        case top
        case middle
        case bottom
    }
    
    private let characters = [
        "donald": goodCharacter,
        "mickey": goodCharacter,
        "goofy": goodCharacter,
        "donaldBad": badCharacter,
        "mickeyBad": badCharacter,
        "goofyBad": badCharacter
    ]
    
    private let characteristics = [goodCharacter, badCharacter]
    
    private var gameTimers = [RunningLine: Timer]()
    private var mainGameTimer: Timer!
    private var mainGameTimerForCountDown: Timer!

    private var remainingTimeLabel: SKLabelNode!
    private var remainingTime = 0 {
        didSet {
            remainingTimeLabel.text = "Timeleft: \(remainingTime)"
        }
    }
    
    private let mainGameTimeLimit = 60
    
    private var currentNumberOfCharactersPerLine = 0
    private var maximumNumberOfCharactersPerLine = 0
    
    //let speedAndNumberOfCharacterPerLine = [-100:]
    private let waveCharSize = [SpeedType.fast: 1, SpeedType.slow: 1.5]
    private let waveCharSpeed = [FlowDirection.ltr: [SpeedType.fast: 500, SpeedType.slow: 250], FlowDirection.rtl: [SpeedType.fast: -700, SpeedType.slow: -250]]
    private let waveCharQuantity = [SpeedType.fast: 10, SpeedType.slow: 5]
    private let waveCharInterval = [SpeedType.fast: 0.38, SpeedType.slow: 1]
    
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var bullets = [SKSpriteNode]()
    private let maximumBulletsPerClip = 6
    private var timerForWarningOfReloadBullets: Timer!
    private var warningOfReloadBulletsLabel: SKLabelNode!
    
    private var gameOverPopup: SKSpriteNode!
    
    private let waveCharLineYAxis = [
        RunningLine.top: 650,
        RunningLine.middle: 384,
        RunningLine.bottom: 148,
    ]
    
    private let waveCharLineXAxis = [
        FlowDirection.ltr: -100,
        FlowDirection.rtl: 1100
    ]
    
    override func didMove(to view: SKView) {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 90, y: 15)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        remainingTimeLabel = SKLabelNode(fontNamed: "Chalkduster")
        remainingTimeLabel.position = CGPoint(x: 1000, y: 15)
        remainingTimeLabel.horizontalAlignmentMode = .right
        remainingTimeLabel.text = "Timeleft: \(mainGameTimeLimit)"
        addChild(remainingTimeLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        var nothingIsTapped = true
        
        let nodes = nodes(at: location)
        
        for eachNode in nodes {
            guard let eachNodeName = eachNode.name else { continue }
            
            // if a character is tapped
            if characteristics.contains(eachNodeName) {
                // if one character is shooted
                if bullets.count > 0 {
                    shootACharacter(character: eachNode)
                }
                
                print("\(eachNodeName) is tapped!")
                nothingIsTapped = false
                break
            }
        }
        
        updateBulletClip(nothingIsTapped)
    }

    override func update(_ currentTime: TimeInterval) {
        for eachCharacter in children {
            guard let eachCharacterName = eachCharacter.name else { continue }
            
            let charPositionX = eachCharacter.position.x
            if characteristics.contains(eachCharacterName) && (charPositionX < -200 || charPositionX > 1200) {
                eachCharacter.removeFromParent()
            }
        }
    }
    
    // MARK: - Extra Funcs
    private func createWave(type: SpeedType, direction: FlowDirection, line: RunningLine) {
        
        guard
            let intervalTime = waveCharInterval[type],
            let tmpMaxTotalCharactersPerLine = waveCharQuantity[type]
        else { return }
        
        maximumNumberOfCharactersPerLine = tmpMaxTotalCharactersPerLine
        currentNumberOfCharactersPerLine = 0
        
        if let lineGameTimer = gameTimers[line] {
            lineGameTimer.invalidate()
        }
        
        let gameTimer = Timer.scheduledTimer(timeInterval: intervalTime, target: self, selector: #selector(createCharacter), userInfo: TimerUserInfo(type: type, direction: direction, line: line), repeats: true)
        
        gameTimers[line] = gameTimer
    }
    
    @objc private func createCharacter(sender: Timer) {
        guard
            let timerUserInfo = sender.userInfo as? TimerUserInfo,
            let characterSpeed = waveCharSpeed[timerUserInfo.direction]?[timerUserInfo.type],
            let characterSize = waveCharSize[timerUserInfo.type],
            let characterPositionY = waveCharLineYAxis[timerUserInfo.line],
            let characterPositionX = waveCharLineXAxis[timerUserInfo.direction],
            let selectedCharacter = characters.randomElement()
        else {
            sender.invalidate()
            return
        }
        
        guard
            currentNumberOfCharactersPerLine < maximumNumberOfCharactersPerLine
        else {
            createWave(type: timerUserInfo.type, direction: timerUserInfo.direction, line: timerUserInfo.line)
            return
        }
        
        let characterPosition = CGPoint(x: characterPositionX, y: characterPositionY)
        
        let charNode = SKSpriteNode(imageNamed: selectedCharacter.key)
        charNode.name = selectedCharacter.value
        charNode.physicsBody = SKPhysicsBody()
        charNode.physicsBody?.velocity = CGVector(dx: characterSpeed, dy: 0)
        charNode.physicsBody?.linearDamping = 0
        charNode.physicsBody?.angularDamping = 0
        charNode.position = characterPosition
        charNode.setScale(Double(characterSize))
        addChild(charNode)
       
        currentNumberOfCharactersPerLine += 1
    }
    
    private func startGame() {
        remainingTime = mainGameTimeLimit
        
        reloadBullets()
        
        createWave(type: SpeedType.fast, direction: FlowDirection.ltr, line: RunningLine.top)
        createWave(type: SpeedType.slow, direction: FlowDirection.rtl, line: RunningLine.middle)
        createWave(type: SpeedType.fast, direction: FlowDirection.ltr, line: RunningLine.bottom)
        
        mainGameTimerForCountDown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMainGameTimerCountDown), userInfo: nil, repeats: true)
        
        mainGameTimer = Timer.scheduledTimer(timeInterval: Double(mainGameTimeLimit), target: self, selector: #selector(gameOver), userInfo: nil, repeats: false)
    }
    
    @objc private func gameOver() {
        for eachCharacter in children {
            guard let eachCharacterName = eachCharacter.name else { continue }
            if characteristics.contains(eachCharacterName) {
                eachCharacter.removeFromParent()
            }
        }
        
        for eachGameTimer in gameTimers.enumerated() {
            eachGameTimer.element.value.invalidate()
        }
        
        stopWarningOfReloadBullets()
        
        mainGameTimer.invalidate()
        mainGameTimerForCountDown.invalidate()
        
        gameOverPopup = SKSpriteNode(imageNamed: "gameOver")
        gameOverPopup.position = CGPoint(x: 512, y: 450)
        gameOverPopup.zPosition = 1
        
        let scoreNote = SKLabelNode(fontNamed: "Chalkduster")
        scoreNote.fontSize = 40
        scoreNote.text = "Final Score: \(score)"
        scoreNote.position = CGPoint(x: 0, y: -100)
        scoreNote.horizontalAlignmentMode = .center
        gameOverPopup.addChild(scoreNote)
        
        let restartLabel = SKLabelNode()
        restartLabel.fontSize = 40
        restartLabel.text = "Restart"
        restartLabel.position = CGPoint(x: 0, y: -200)
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.name = "restartButton"
        gameOverPopup.addChild(restartLabel)
        
        addChild(gameOverPopup)
    }
    
    @objc private func updateMainGameTimerCountDown() {
        guard remainingTime > 0 else { return }
        remainingTime -= 1
    }
    
    
    // MARK: Bullets
    private func reloadBullets() {
        stopWarningOfReloadBullets()
        
        for i in 1...maximumBulletsPerClip {
            let bullet = SKSpriteNode(imageNamed: "bullet")
            bullet.position = CGPoint(x: 440 + (i*20), y: 30)
            bullet.name = "bullet\(i)"
            addChild(bullet)
            
            bullets.append(bullet)
        }
    }
    
    private func updateBulletClip(_ nothingIsTapped: Bool) {
        if bullets.count == 0 {
            // reload clip if nothing is tapped
            if nothingIsTapped {
                reloadBullets()
            } else {
                print("WARNING TO RELOAD BULLETS")
                // warning: reload clip
                warnToReloadBullets()
            }
        } else {
            // remove one bullet from clip
            guard let lastBullet = bullets.last else { return }
            lastBullet.removeFromParent()
            bullets = bullets.dropLast()
            
            print("bullets: \(bullets.count)")
        }
    }
    
    private func warnToReloadBullets() {
        timerForWarningOfReloadBullets = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(showWarningOfReloadBullets), userInfo: nil, repeats: true)
    }
    
    @objc private func showWarningOfReloadBullets() {
        if warningOfReloadBulletsLabel == nil {
            warningOfReloadBulletsLabel = SKLabelNode(fontNamed: "Chalkduster")
            warningOfReloadBulletsLabel.text = "RELOAD!"
            warningOfReloadBulletsLabel.position = CGPoint(x: 512, y: 15)
            warningOfReloadBulletsLabel.name = "warningOfReloadBullets"
        }
        
        if childNode(withName: "warningOfReloadBullets") == nil {
            addChild(warningOfReloadBulletsLabel)
        } else {
            hideWarningOfreloadBulletsLabel()
        }
    }
    
    private func stopWarningOfReloadBullets() {
        if timerForWarningOfReloadBullets != nil {
            timerForWarningOfReloadBullets.invalidate()
        }
        
        hideWarningOfreloadBulletsLabel()
    }
    
    private func hideWarningOfreloadBulletsLabel() {
        guard warningOfReloadBulletsLabel != nil else { return }
        warningOfReloadBulletsLabel.removeFromParent()
    }
    
    private func shootACharacter(character: SKNode) {
        
    }
}
