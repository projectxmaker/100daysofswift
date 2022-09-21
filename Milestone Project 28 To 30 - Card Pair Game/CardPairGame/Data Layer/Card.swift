//
//  Card.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/19/22.
//

import Foundation

struct Card {
    enum State {
        case faceUp
        case faceDown
        case resolved
    }
    
    var index: Int
    var name: String
    var state: State
    
    mutating func setState(newState: State) {
        state = newState
    }
}
