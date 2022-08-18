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
    
    private let characters = ["donald", "mickey", "goofy"]
    private var gameTimers = [RunningLine: Timer]()
    
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
        
        createWave(type: SpeedType.fast, direction: FlowDirection.ltr, line: RunningLine.top)
        createWave(type: SpeedType.slow, direction: FlowDirection.rtl, line: RunningLine.middle)
        createWave(type: SpeedType.fast, direction: FlowDirection.ltr, line: RunningLine.bottom)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func update(_ currentTime: TimeInterval) {
        for eachCharacter in children {
            let charPositionX = eachCharacter.position.x
            let charPositionY = eachCharacter.position.y
            if eachCharacter.name == "character" && (charPositionX < -200 || charPositionX > 1200) {
                eachCharacter.removeFromParent()
                print("destroy \(eachCharacter.name ?? "character") at \(charPositionX):\(charPositionY)")
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
            let charType = characters.randomElement()
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
        
        let charNode = SKSpriteNode(imageNamed: charType)
        charNode.physicsBody = SKPhysicsBody()
        charNode.physicsBody?.velocity = CGVector(dx: characterSpeed, dy: 0)
        charNode.physicsBody?.linearDamping = 0
        charNode.physicsBody?.angularDamping = 0
        charNode.position = characterPosition
        charNode.setScale(Double(characterSize))
        charNode.name = "character"
        addChild(charNode)
       
        currentNumberOfCharactersPerLine += 1
    }
}
