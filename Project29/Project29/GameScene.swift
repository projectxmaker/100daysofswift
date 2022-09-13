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

    override func didMove(to view: SKView) {
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
