//
//  CardsManager.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/19/22.
//

import Foundation

class CardPairManager {
    static let shared = CardPairManager()
    var cardPairs = [CardPair]()
    
    init() {
        if cardPairs.isEmpty {
            loadCards()
        }
    }
    
    func resetCards() {
        DispatchQueue.global().async {
            if self.hasUserDefinedCardFile() {
                let userDefinedCardsFileURL = self.getUserDefinedCarfFileURL()
                try? FileManager.default.removeItem(at: userDefinedCardsFileURL)
                
                NotificationCenter.default.post(name: NSNotification.Name("com.projectxmaker.cardgame.ResetCardPairListNotification"), object: nil)
            }
        }
    }
    
    func getURLOfAppDocumentDirectory() -> URL {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }

    func getUserDefinedCarfFileURL() -> URL {
        let userDefinedFileName = "user-defined-cards.txt"
        let appDocumentDirectionUrl = getURLOfAppDocumentDirectory()
        var userDefinedFileURL: URL
        
        if #available(iOS 16.0, *) {
            userDefinedFileURL = appDocumentDirectionUrl.appending(component: userDefinedFileName)
        } else {
            userDefinedFileURL = appDocumentDirectionUrl.appendingPathComponent(userDefinedFileName)
        }
        
        return userDefinedFileURL
    }
    
    func getPathOfURL(_ url: URL) -> String {
        var userDefinedFilePath: String
        
        if #available(iOS 16.0, *) {
            userDefinedFilePath = url.path()
        } else {
            userDefinedFilePath = url.path
        }
        
        return userDefinedFilePath
    }
    
    func hasUserDefinedCardFile() -> Bool {
        let userDefinedFileURL = getUserDefinedCarfFileURL()
        return FileManager.default.fileExists(atPath: getPathOfURL(userDefinedFileURL))
    }
    
    func loadCards() {
        DispatchQueue.global().async {
            var cardFileUrl: URL
            
            // if user-defined cards file txt exists, load it, otherwise, use app-defined cards file
            if self.hasUserDefinedCardFile() {
                cardFileUrl = self.getUserDefinedCarfFileURL()
            } else {
                guard
                    let tmpURL = Bundle.main.url(forResource: "cards", withExtension: "txt")
                else { return }
                cardFileUrl = tmpURL
            }
            
            guard
                let data = try? Data(contentsOf: cardFileUrl),
                let decodedData = try? JSONDecoder().decode([CardPair].self, from: data)
            else { return }
            
            self.cardPairs.removeAll(keepingCapacity: true)
            
            for eachCardPair in decodedData {
                let newCardPair = CardPair(first: eachCardPair.first, second: eachCardPair.second)
                self.cardPairs.append(newCardPair)
            }
        }
    }
    
    func addNewCardPair(first: String, second: String) {
        let cardPair = CardPair(first: first, second: second)
        cardPairs.insert(cardPair, at: 0)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
    }
    
    func editCardPair(at: IndexPath, first: String, second: String) {
        cardPairs[at.row] = CardPair(first: first, second: second)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
    }
    
    func deleteCardPair(at: IndexPath) {
        cardPairs.remove(at: at.row)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
    }
    
    func updateUserDefinedCardsFile() {
        DispatchQueue.global().async {
            let fileURL = self.getUserDefinedCarfFileURL()
            
            let data = try? JSONEncoder().encode(self.cardPairs)
            try? data?.write(to: fileURL)
        }
    }
    
    func getCardPairs(numberOfCardPairs: Int? = nil) -> [CardPair] {
        var shuffledCardPairs: [CardPair]
        if let numberOfCardPairs {
            shuffledCardPairs = Array(cardPairs.shuffled()[0..<numberOfCardPairs])
        } else {
            shuffledCardPairs = cardPairs
        }
        
        return shuffledCardPairs
    }
    
    func getCards(numberOfCards: Int) -> [Card] {
        guard numberOfCards % 2 == 0 else { return [Card]() }
        
        let numberOfCardPairds = numberOfCards / 2
        let cardPairs = getCardPairs(numberOfCardPairs: numberOfCardPairds)
        
        var cards = [Card]()
        for (index, eachCardPair) in cardPairs.enumerated() {
            cards.append(Card(index: index, name: eachCardPair.first, state: Card.State.faceDown))
            cards.append(Card(index: index, name: eachCardPair.second, state: Card.State.faceDown))
        }
        
        return cards
    }
}
