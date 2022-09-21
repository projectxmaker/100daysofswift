//
//  CardListTableViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/18/22.
//

import UIKit
import LocalAuthentication

class CardListTableViewController: UITableViewController {

    var settingsBarButtonItem: UIBarButtonItem!
    var addNewCardBarButtonItem: UIBarButtonItem!
    
    var lockAppBarButtonItem: UIBarButtonItem!
    
    var cardsManager = CardPairManager.shared
    
    var enabledBiometric = false
    var enabledPasscodeState = false
    var passcode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cards"

        setupNavigationItems()
        setupNotifcationObservers()
        loadCardsInBackground()
        loadSecuritySettings()
        runSecurity()
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
        return cardsManager.getCardPairs().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardPairCell", for: indexPath)

        let card = cardsManager.getCardPairs()[indexPath.row]
        
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
        navigationItem.hidesBackButton = false
        navigationItem.leftItemsSupplementBackButton = true

    }
    
    @objc func handleSettingsBarButtonItemTapped() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = mainStoryboard.instantiateViewController(withIdentifier: "SettingsView")
        
        navigationController?.pushViewController(settingsVC, animated: true)
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
    func loadCardsInBackground() {
        performSelector(inBackground: #selector(loadCards), with: nil)
    }
    
    @objc func loadCards() {
        cardsManager.loadCards()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func addNewCard(first: String, second: String) {
        cardsManager.addNewCardPair(first: first, second: second)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func editCard(at: IndexPath, first: String, second: String) {
        cardsManager.editCardPair(at: at, first: first, second: second)
        tableView.reloadRows(at: [at], with: .automatic)
    }
    
    func deleteCard(at: IndexPath) {
        cardsManager.deleteCardPair(at: at)
        tableView.deleteRows(at: [at], with: .automatic)
    }
    
    func showEditAlertForCard(at: IndexPath) {
        let cardIndex = at.row
        let card = cardsManager.getCardPairs()[cardIndex]
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
    
    func showAlertToConfirmDeletion(at: IndexPath) {
        let cardIndex = at.row
        let card = cardsManager.getCardPairs()[cardIndex]
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
    
    // MARK: - Security
    
    func loadSecuritySettings() {
        enabledBiometric = UserDefaults.standard.bool(forKey: SettingsViewController.Keys.biometricSettingKey)
        enabledPasscodeState = UserDefaults.standard.bool(forKey: SettingsViewController.Keys.passcodeStateSettingKey)
        passcode = UserDefaults.standard.string(forKey: SettingsViewController.Keys.passcodeSettingKey)
    }
    
    func runSecurity() {
        if enabledBiometric || enabledPasscodeState {
            switchVisibilityOfCardList(isHidden: true)
            authenticate()
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if enabledBiometric {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "It's used to unlock Card Management feature!"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async {
                        if success {
                            self?.tableView.isHidden = false
                        } else {
                            let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                            
                            if self?.enabledPasscodeState == true {
                                ac.addTextField { textfield in
                                    textfield.placeholder = "Input passcode"
                                }
                                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                                    let passcode = ac?.textFields?[0].text ?? ""
                                    self?.evaluateInputtedPasscode(passcode)
                                }))
                            } else {
                                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                            }

                            ac.popoverPresentationController?.barButtonItem = self?.navigationItem.rightBarButtonItem
                            self?.present(ac, animated: true)
                        }
                    }
                }
            } else {
                var info = "Your device is not configured for biometric authentication."
                info += (self.enabledPasscodeState) ? " Input passcode instead." : ""
                let ac = UIAlertController(title: "Biometry unavailable", message: info, preferredStyle: .alert)
                
                if self.enabledPasscodeState == true {
                    ac.addTextField { textfield in
                        textfield.placeholder = "Input passcode"
                    }
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                        let passcode = ac?.textFields?[0].text ?? ""
                        self?.evaluateInputtedPasscode(passcode)
                    }))
                } else {
                    ac.addAction(UIAlertAction(title: "Ok", style: .default))
                }
                
                ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
                present(ac, animated: true)
            }
        } else {
            var info = "Input passcode to unlock Card Management feature."
            let ac = UIAlertController(title: "Biometry unavailable", message: info, preferredStyle: .alert)
            
            ac.addTextField { textfield in
                textfield.placeholder = "Input passcode"
            }
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                let passcode = ac?.textFields?[0].text ?? ""
                self?.evaluateInputtedPasscode(passcode)
            }))

            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(ac, animated: true)
        }

    }
    
    func evaluateInputtedPasscode(_ inputtedPassword: String) {
        if let passcode = passcode {
            if passcode == inputtedPassword {
                switchVisibilityOfCardList(isHidden: false)
            } else {
                showAlertOfInvalidPasscode()
            }
        } else {
            showAlertOfInvalidPasscode()
        }
    }
    
    func showAlertOfInvalidPasscode() {
        if enabledPasscodeState == true {
            let ac = UIAlertController(title: "Invalid Passcode", message: "Inputted passcode is incorrect.", preferredStyle: .alert)
            ac.addTextField { textfield in
                textfield.placeholder = "Input passcode"
                textfield.isSecureTextEntry = true
            }
            ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                let passcode = ac?.textFields?[0].text ?? ""
                self?.evaluateInputtedPasscode(passcode)
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(ac, animated: true)
        }
    }
    
    func switchVisibilityOfCardList(isHidden: Bool) {
        if isHidden {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
    }
    
    // MARK: - Notification
    func setupNotifcationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleResetCardPairListNotification(_:)), name: NSNotification.Name("com.projectxmaker.cardgame.ResetCardPairListNotification"), object: nil)
    }

    @objc func handleResetCardPairListNotification(_ notification: Notification) {
        loadCardsInBackground()
    }
}
