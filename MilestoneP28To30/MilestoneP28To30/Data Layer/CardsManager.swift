//
//  CardsManager.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/19/22.
//

import Foundation

class CardsManager {
    static let shared = CardsManager()
    
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
}
