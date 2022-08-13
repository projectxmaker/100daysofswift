//
//  WhackSlot.swift
//  Project14
//
//  Created by Pham Anh Tuan on 8/13/22.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    func config(at: CGPoint) {
        position = at
        
        let hole = SKSpriteNode(imageNamed: "whackHole")
        addChild(hole)
        
        let mask = SKCropNode()
        mask.zPosition = 1
        mask.position = CGPoint(x: 0, y: 10)
        mask.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        let penguinGood = SKSpriteNode(imageNamed: "penguinGood")
        penguinGood.position = CGPoint(x: 0, y: -90)
        
        mask.addChild(penguinGood)
        
        addChild(mask)
    }
}
