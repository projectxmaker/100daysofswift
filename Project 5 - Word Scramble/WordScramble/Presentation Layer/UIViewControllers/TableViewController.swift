//
//  TableViewController.swift
//  Project5
//
//  Created by Pham Anh Tuan on 7/30/22.
//

import UIKit

class TableViewController: UITableViewController {

    private var allWords = [String]()
    private var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadWordsFromFile()
        loadCurrentResult()
        setupButtonsOfNavigationBar()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewController.keys.tableReusableCellIdentifier, for: indexPath)

        // Configure the cell...
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = usedWords[indexPath.row]
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 30)
        cell.contentConfiguration = contentConfig

        return cell
    }

    // MARK: - Extra Functions
    private func loadWordsFromFile() {
        guard
            let filePath = Bundle.main.path(forResource: TableViewController.keys.wordFileName, ofType: TableViewController.keys.wordFileExtension),
            let fileContent = try? String(contentsOfFile: filePath)
        else { return }
        
        allWords = fileContent.components(separatedBy: TableViewController.keys.wordFileBreakLineCharacter)
        
        if allWords.isEmpty {
            allWords = TableViewController.keys.defaultAllWords
        }
    }
    
    @objc private func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        
        saveCurrentResult()
    }
    
    private func setupButtonsOfNavigationBar() {
        setupAnswerButton()
        setupRestartGameButton()
    }
    
    private func setupAnswerButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAnswerButtonTapped))
    }
    
    private func setupRestartGameButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
    }
    
    @objc private func handleAnswerButtonTapped() {
        let ac = UIAlertController(title: TableViewController.keys.alertAnswerFormTitle, message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitButton = UIAlertAction(title: TableViewController.keys.alertAnswerSubmitButtonTitle, style: .default) { [weak ac, weak self] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitButton)
        
        present(ac, animated: true, completion: nil)
    }
    
    private func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        guard let title = title?.lowercased() else { return }
        
        if isValidLength(word: lowerAnswer) {
            if isTheStartWord(word: lowerAnswer) {
                if isPossible(word: lowerAnswer) {
                    if isOriginal(word: lowerAnswer) {
                        if isReal(word: lowerAnswer) {
                            usedWords.insert(lowerAnswer, at: 0)
                            
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            
                            saveCurrentResult()
                            
                            return
                        } else {
                            showErrorMessage(title: TableViewController.keys.errorTitleOfIsNotReal, message: TableViewController.keys.errorMessageOfIsNotReal)
                        }
                    } else {
                        showErrorMessage(title: TableViewController.keys.errorTitleOfIsNotOriginal, message: TableViewController.keys.errorMessageOfIsNotOriginal)
                    }
                } else {
                    showErrorMessage(title: TableViewController.keys.errorTitleOfIsNotPossible, message: "\(TableViewController.keys.errorMessageOfIsNotPossible) \(title)")
                }
            } else {
                showErrorMessage(title: TableViewController.keys.errorTitleOfIsTheStartWord, message: "\(TableViewController.keys.errorMessageOfIsTheStartWord) \(title)")
            }
        } else {
            showErrorMessage(title: TableViewController.keys.errorTitleOfIsInvalidLength, message: "\(TableViewController.keys.errorMessageOfIsInvalidLength) \(TableViewController.keys.inputMinimumLength)")
        }
    }
    
    private func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false}
        
        for letter in word {
            if let letterIndex = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: letterIndex)
            } else {
                return false
            }
        }
        
        return true
    }
    
    private func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: TableViewController.keys.spellCheckLanguage)
        
        return misspelledRange.location == NSNotFound
    }
    
    private func isValidLength(word: String) -> Bool {
        word.count >= TableViewController.keys.inputMinimumLength
    }
    
    private func isTheStartWord(word: String) -> Bool {
        guard
              let lowerTitle = title?.lowercased(),
              word == lowerTitle
        else { return true }
        
        return false
    }
    
    private func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: TableViewController.keys.alertInvalidInputButtonTitle, style: .default))
        present(ac, animated: true)
    }
    
    private func saveCurrentResult() {
        let defaultData = UserDefaults.standard
        defaultData.set(title, forKey: "title")
        defaultData.set(usedWords, forKey: "usedWords")
    }
    
    private func loadCurrentResult() {
        let defaultData = UserDefaults.standard
        
        guard
            let tmpTitle = defaultData.string(forKey: "title"),
            let tmpUsedWords = defaultData.array(forKey: "usedWords") as? [String]
        else {
            startGame()
            return
        }
        
        title = tmpTitle
        usedWords = tmpUsedWords
        tableView.reloadData()
    }

}
