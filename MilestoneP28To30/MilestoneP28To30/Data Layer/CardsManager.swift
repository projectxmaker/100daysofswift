//
//  CardsManager.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/19/22.
//

import Foundation

class CardsManager {
    static let shared = CardsManager()
    var cards = [Card]()
    
    func resetCards() {
        DispatchQueue.global().async {
            if self.hasUserDefinedCardFile() {
                let userDefinedCardsFileURL = self.getUserDefinedCarfFileURL()
                try? FileManager.default.removeItem(at: userDefinedCardsFileURL)
                
                NotificationCenter.default.post(name: NSNotification.Name("com.projectxmaker.cardgame.ResetCardListNotification"), object: nil)
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
        var cardFileUrl: URL
        
        // if user-defined cards file txt exists, load it, otherwise, use app-defined cards file
        if hasUserDefinedCardFile() {
            cardFileUrl = getUserDefinedCarfFileURL()
        } else {
            guard
                let tmpURL = Bundle.main.url(forResource: "cards", withExtension: "txt")
            else { return }
            cardFileUrl = tmpURL
        }
        
        guard
            let data = try? Data(contentsOf: cardFileUrl),
            let decodedData = try? JSONDecoder().decode([Card].self, from: data)
        else { return }
        
        cards.removeAll(keepingCapacity: true)
        
        for card in decodedData {
            let card = Card(first: card.first, second: card.second)
            cards.append(card)
        }
    }
    
    func addNewCard(first: String, second: String) {
        let card = Card(first: first, second: second)
        cards.insert(card, at: 0)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
    }
    
    func editCard(at: IndexPath, first: String, second: String) {
        cards[at.row] = Card(first: first, second: second)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
    }
    
    func deleteCard(at: IndexPath) {
        cards.remove(at: at.row)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
    }
    
    func updateUserDefinedCardsFile() {
        DispatchQueue.global().async {
            let fileURL = self.getUserDefinedCarfFileURL()
            
            let data = try? JSONEncoder().encode(self.cards)
            try? data?.write(to: fileURL)
        }
    }
}
