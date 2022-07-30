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
        startGame()
        setupAnswerButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)

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
            let filePath = Bundle.main.path(forResource: "start", ofType: "txt"),
            let fileContent = try? String(contentsOfFile: filePath)
        else { return }
        
        allWords = fileContent.components(separatedBy: "\n")
        
        if allWords.isEmpty {
            allWords = ["xwyalkua"]
        }
    }
    
    private func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    private func setupAnswerButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAnswerButtonTapped))
    }
    
    @objc private func handleAnswerButtonTapped() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitButton = UIAlertAction(title: "Answer", style: .default) { [weak ac, weak self] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitButton)
        
        present(ac, animated: true, completion: nil)
    }
    
    private func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(lowerAnswer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    private func isPossible(word: String) -> Bool {
        true
    }
    
    private func isOriginal(word: String) -> Bool {
        true
    }
    
    private func isReal(word: String) -> Bool {
        true
    }

}
