//
//  Constant.swift
//  Project5
//
//  Created by Pham Anh Tuan on 7/30/22.
//

import Foundation

extension TableViewController {
    struct keys {
        static let tableReusableCellIdentifier = "Word"
        
        static let wordFileName = "start"
        static let wordFileExtension = "txt"
        static let wordFileBreakLineCharacter = "\n"
        
        static let defaultAllWords = ["aardvark"]
        static let inputMinimumLength = 3
        
        static let spellCheckLanguage = "en"
        
        
        static let alertAnswerFormTitle = "Enter answer"
        static let alertAnswerSubmitButtonTitle = "Answer"
        
        static let alertInvalidInputButtonTitle = "OK"
        
        static let errorTitleOfIsNotReal = "Word not recognised"
        static let errorMessageOfIsNotReal = "You can't just make them up, you know!"
        static let errorTitleOfIsNotOriginal = "Word used already"
        static let errorMessageOfIsNotOriginal = "Be more original!"
        static let errorTitleOfIsNotPossible = "Word not possible"
        static let errorMessageOfIsNotPossible = "You can't spell that word from"
        static let errorTitleOfIsTheStartWord = "Word not possible"
        static let errorMessageOfIsTheStartWord = "You can't just put the same word of"
        static let errorTitleOfIsInvalidLength = "Word not possible"
        static let errorMessageOfIsInvalidLength = "The length of word must be equal or greater than"
    }
}
