//
//  CardListTableViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/18/22.
//

import UIKit
import LocalAuthentication

class CardListTableViewController: UITableViewController {
    var appEngine = AppEngine()
    
    var settingsBarButtonItem: UIBarButtonItem!
    var addNewCardBarButtonItem: UIBarButtonItem!
    
    var lockAppBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Card Pairs"
        
        setupNavigationItems()
        setupNotifcationObservers()
        loadCardsInBackground()
        runSecurity()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return appEngine.cardPairManager.getCardPairs().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardPairCell", for: indexPath)

        let card = appEngine.cardPairManager.getCardPairs()[indexPath.row]
        
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
        switchVisibilityOfCardList(isHidden: true)
    }
    
    @objc func handleUnlockAppBarButtonItemTapped() {
        runSecurity()
    }
    
    // MARK: - Extra Funcs
    func loadCardsInBackground() {
        performSelector(inBackground: #selector(loadCards), with: nil)
    }
    
    @objc func loadCards() {
        appEngine.cardPairManager.loadCards()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func addNewCard(first: String, second: String) {
        appEngine.cardPairManager.addNewCardPair(first: first, second: second)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func editCard(at: IndexPath, first: String, second: String) {
        appEngine.cardPairManager.editCardPair(at: at, first: first, second: second)
        tableView.reloadRows(at: [at], with: .automatic)
    }
    
    func deleteCard(at: IndexPath) {
        appEngine.cardPairManager.deleteCardPair(at: at)
        tableView.deleteRows(at: [at], with: .automatic)
    }
    
    func showEditAlertForCard(at: IndexPath) {
        let cardIndex = at.row
        let card = appEngine.cardPairManager.getCardPairs()[cardIndex]
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
        let card = appEngine.cardPairManager.getCardPairs()[cardIndex]
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
    func runSecurity() {
        if appEngine.settings.biometricState || appEngine.settings.passcodeState {
            switchVisibilityOfCardList(isHidden: true)
            authenticate()
        } else {
            switchVisibilityOfCardList(isHidden: false)
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if appEngine.settings.biometricState {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "It's used to unlock Card Management feature!"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async {
                        if success {
                            self?.switchVisibilityOfCardList(isHidden: false)
                        } else {
                            let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                            
                            if self?.appEngine.settings.passcodeState == true {
                                ac.addTextField { textfield in
                                    textfield.enablePasswordToggle()
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
                info += (appEngine.settings.passcodeState) ? " Input passcode instead." : ""
                let ac = UIAlertController(title: "Biometry unavailable", message: info, preferredStyle: .alert)
                
                if appEngine.settings.passcodeState == true {
                    ac.addTextField { textfield in
                        textfield.enablePasswordToggle()
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
            let info = "Input passcode to unlock Card Management feature."
            let ac = UIAlertController(title: "Biometry unavailable", message: info, preferredStyle: .alert)
            
            ac.addTextField { textfield in
                textfield.enablePasswordToggle()
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
        if let passcode = appEngine.settings.passcode {
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
        if appEngine.settings.passcodeState == true {
            let ac = UIAlertController(title: "Invalid Passcode", message: "Inputted passcode is incorrect.", preferredStyle: .alert)
            ac.addTextField { textfield in
                textfield.enablePasswordToggle()
                textfield.placeholder = "Input passcode"
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
            addNewCardBarButtonItem.isEnabled = false
            settingsBarButtonItem.isEnabled = false
            lockAppBarButtonItem.image = UIImage(systemName: "lock.open")
            lockAppBarButtonItem.action = #selector(handleUnlockAppBarButtonItemTapped)
        } else {
            tableView.isHidden = false
            addNewCardBarButtonItem.isEnabled = true
            settingsBarButtonItem.isEnabled = true
            lockAppBarButtonItem.image = UIImage(systemName: "lock")
            lockAppBarButtonItem.action = #selector(handleLockAppBarButtonItemTapped)
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
