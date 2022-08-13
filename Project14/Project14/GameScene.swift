//
//  GameScene.swift
//  Project14
//
//  Created by Pham Anh Tuan on 8/13/22.
//

import SpriteKit

class GameScene: SKScene {
    var popupTime = 0.85
    
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var slots = [WhackSlot]()
    
    private var numberOfWaves = 0
    private var maximumWaves = 30
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.text = "Score: 0"
        gameScore.fontSize = 48
        gameScore.horizontalAlignmentMode = .left
        addChild(gameScore)
        
        setupWhackSlots()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.newWave()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for eachNode in nodes {
            guard let whackSlot = eachNode.parent?.parent as? WhackSlot else {
                continue
            }
            
            whackSlot.hit(next: updateScore)
        }
    }
    
    // MARK: - Extra Funcs
    
    private func setupWhackSlots() {
        for i in 0..<5 {
            createWhackSlot(at: CGPoint(x: 100 + (i * 170), y: 410))
        }
        
        for i in 0..<4 {
            createWhackSlot(at: CGPoint(x: 180 + (i * 170), y: 320))
        }
        
        for i in 0..<5 {
            createWhackSlot(at: CGPoint(x: 100 + (i * 170), y: 230))
        }
        
        for i in 0..<4 {
            createWhackSlot(at: CGPoint(x: 180 + (i * 170), y: 140))
        }
    }
    
    private func createWhackSlot(at: CGPoint) {
        let slot = WhackSlot()
        slot.config(at: at)
        
        addChild(slot)
        
        slots.append(slot)
    }

    private func newWave() {
        numberOfWaves += 1
        
        if numberOfWaves > maximumWaves {
            for eachSlot in slots {
                eachSlot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)

            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0..<12) > 4 {
            slots[1].show(hideTime: popupTime)
        }
        
        if Int.random(in: 0..<12) > 8 {
            slots[2].show(hideTime: popupTime)
        }
        
        if Int.random(in: 0..<12) > 10 {
            slots[3].show(hideTime: popupTime)
        }
        
        if Int.random(in: 0..<12) > 11 {
            slots[4].show(hideTime: popupTime)
        }
        
        let minDelay = popupTime * 0.5
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.newWave()
        }
    }
    
    private func updateScore(_ whackSlot: WhackSlot) {
        let hitToCharType = whackSlot.hitToWhichCharType

        if hitToCharType == .charGood {
            self.score -= 5
        } else if hitToCharType == .charEvil {
            self.score += 1
        }
    }
}
