//
//  Constants.swift
//  MilestoneP16To18
//
//  Created by Pham Anh Tuan on 8/19/22.
//

import Foundation

extension GameScene {
    struct keys {
        static let goodCharacter = "good"
        static let badCharacter = "bad"
        static let smallCharacter = "small"
        static let bigCharacter = "big"
        
        static let characteristics = [GameScene.keys.goodCharacter, GameScene.keys.badCharacter]
        static let characterScaleTypes = [GameScene.keys.smallCharacter, GameScene.keys.bigCharacter]
        
        static let characters = [
            "donald": GameScene.keys.goodCharacter,
            "mickey": GameScene.keys.goodCharacter,
            "goofy": GameScene.keys.goodCharacter,
            "donaldBad": GameScene.keys.badCharacter,
            "mickeyBad": GameScene.keys.badCharacter,
            "goofyBad": GameScene.keys.badCharacter
        ]
        
        static let scoreRules = [
            "small|bad": -1,
            "small|good": 3,
            "big|bad": -3,
            "big|good": 1
        ]
    }
}
