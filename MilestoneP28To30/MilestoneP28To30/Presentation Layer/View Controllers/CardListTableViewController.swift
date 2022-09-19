//
//  CardListTableViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/18/22.
//

import UIKit

class CardListTableViewController: UITableViewController {

    var cards = [Card]()
    var settingsBarButtonItem: UIBarButtonItem!
    var addNewCardBarButtonItem: UIBarButtonItem!
    
    var lockAppBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cards"

        setupNavigationItems()
        
        performSelector(inBackground: #selector(loadCards), with: nil)
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
        return cards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath)

        let card = cards[indexPath.row]
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = card.first
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        contentConfig.secondaryText = card.second
        contentConfig.secondaryTextProperties.font = UIFont.systemFont(ofSize: 18)
        cell.contentConfiguration = contentConfig

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showEditAlertForCard(at: indexPath)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Bar Button Item Functions
    func setupNavigationItems() {
        settingsBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(handleSettingsBarButtonItemTapped))
        addNewCardBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(handleAddNewCardBarButtonItemTapped))

        // lock.open
        lockAppBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(handleLockAppBarButtonItemTapped))
        
        navigationItem.rightBarButtonItems = [
            settingsBarButtonItem,
            addNewCardBarButtonItem
        ]
        
        navigationItem.leftBarButtonItem = lockAppBarButtonItem
    }
    
    @objc func handleSettingsBarButtonItemTapped() {
        
    }
    
    @objc func handleAddNewCardBarButtonItemTapped() {
        let ac = UIAlertController(title: "Add New Card", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "1st card"
        }
        ac.addTextField { textfield in
            textfield.placeholder = "2nd card"
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self, weak ac] _ in
            guard
                let firstCard = ac?.textFields?[0].text,
                !firstCard.isEmpty,
                let secondCard = ac?.textFields?[1].text,
                !secondCard.isEmpty
            else { return }
            
            self?.addNewCard(first: firstCard, second: secondCard)
        }))
        
        if #available(iOS 16.0, *) {
            ac.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(ac, animated: true)
    }
    
    @objc func handleLockAppBarButtonItemTapped() {
        
    }
    
    // MARK: - Extra Funcs
    @objc func loadCards() {
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
        
        for card in decodedData {
            let card = Card(first: card.first, second: card.second)
            cards.append(card)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func addNewCard(first: String, second: String) {
        let card = Card(first: first, second: second)
        cards.insert(card, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
    }
    
    func showEditAlertForCard(at: IndexPath) {
        let cardIndex = at.row
        let card = cards[cardIndex]
        let info = "Edit a card pair"
        
        let ac = UIAlertController(title: "Card Pair", message: info, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.text = card.first
        }
        ac.addTextField { textfield in
            textfield.text = card.second
        }
        
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak ac] _ in
            guard
                let firstCard = ac?.textFields?[0].text,
                !firstCard.isEmpty,
                let secondCard = ac?.textFields?[1].text,
                !secondCard.isEmpty
            else { return }
            
            self?.editCard(at: at, first: firstCard, second: secondCard)
        }))
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            self?.showAlertToConfirmDeletion(at: at)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if #available(iOS 16.0, *) {
            ac.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(ac, animated: true)
    }
    
    func editCard(at: IndexPath, first: String, second: String) {
        cards[at.row] = Card(first: first, second: second)
        tableView.reloadRows(at: [at], with: .automatic)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
    }
    
    func showAlertToConfirmDeletion(at: IndexPath) {
        let cardIndex = at.row
        let card = cards[cardIndex]
        let info = """
        Do you want to delete this card pair:
        \(card.first)
        \(card.second)
        """
        
        let ac = UIAlertController(title: "Delete Card Pair", message: info, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            self?.deleteCard(at: at)
        }))
        
        if #available(iOS 16.0, *) {
            ac.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(ac, animated: true)
    }
    
    func deleteCard(at: IndexPath) {
        cards.remove(at: at.row)
        tableView.deleteRows(at: [at], with: .automatic)
        
        // update user-defined cards file
        updateUserDefinedCardsFile()
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
    
    func updateUserDefinedCardsFile() {
        DispatchQueue.global().async {
            let fileURL = self.getUserDefinedCarfFileURL()
            
            let data = try? JSONEncoder().encode(self.cards)
            try? data?.write(to: fileURL)
        }
    }
}
