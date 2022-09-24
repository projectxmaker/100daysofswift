//
//  CardGameEngine.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/20/22.
//

import Foundation

struct CardGameEngine {
    var cardPairManager: CardPairManager
    
    var beingFacedUpCardIndexes = [Int]()
    var cardsInCurrentRound = [Card]()
    
    let numberOfCardsPerRound = 16
    
    init(cardPairManager: CardPairManager) {
        self.cardPairManager = cardPairManager
    }
    
    mutating func handleCardTapped(cardIndex: Int) -> Bool {
        var stateChanged = false
        
        if cardsInCurrentRound[cardIndex].state == Card.State.faceDown {
            stateChanged = true
            cardsInCurrentRound[cardIndex].setState(newState: .faceUp)
            
            beingFacedUpCardIndexes.append(cardIndex)
        }

        return stateChanged
    }
    
    func numberOfCardsFaceUp() -> Int {
        return beingFacedUpCardIndexes.count
    }
    
    func canResolvedFacedUpCards() -> Bool {
        var canResolve = false
        
        let firstCard = cardsInCurrentRound[beingFacedUpCardIndexes[0]]
        let secondCard = cardsInCurrentRound[beingFacedUpCardIndexes[1]]
        
        if firstCard.index == secondCard.index {
            canResolve = true
        }
        
        return canResolve
    }
    
    mutating func evaluateFacedUpCards(executeIfResolved: (_ cardIndexes: [Int]) -> Void, executeIfFaceDown: (_ cardIndexes: [Int]) -> Void) {
        if beingFacedUpCardIndexes.count == 2 {
            let cardIndexes = beingFacedUpCardIndexes
            var newState: Card.State = .faceDown
            
            if canResolvedFacedUpCards() {
                newState = .resolved
            }
            
            for eachCardIndex in beingFacedUpCardIndexes {
                cardsInCurrentRound[eachCardIndex].setState(newState: newState)
            }
            
            beingFacedUpCardIndexes.removeAll(keepingCapacity: true)
            
            if newState == .resolved {
                executeIfResolved(cardIndexes)
            } else {
                executeIfFaceDown(cardIndexes)
            }
        }
    }
    
    mutating func generateCards() {
        cardsInCurrentRound = cardPairManager.getCards(numberOfCards: numberOfCardsPerRound).shuffled()
    }
    
    mutating func getCards() -> [Card] {
        if cardsInCurrentRound.isEmpty {
            generateCards()
        }
        
        return cardsInCurrentRound
    }
    
    func getCard(cardIndex: Int) -> Card {
        return cardsInCurrentRound[cardIndex]
    }
    
    func isAllCardsResolved() -> Bool {
        return cardsInCurrentRound.allSatisfy { card in
            card.state == .resolved
        }
    }
}
