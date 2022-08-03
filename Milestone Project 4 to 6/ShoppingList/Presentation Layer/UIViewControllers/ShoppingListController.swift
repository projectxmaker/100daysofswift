//
//  ShoppingListController.swift
//  ShoppingList
//
//  Created by Pham Anh Tuan on 8/2/22.
//

import UIKit

class ShoppingListController: UITableViewController {

    private var itemList: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonsOfNavigationItem()
        resetItemList()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)

        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = itemList[indexPath.row]
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 30)
        cell.contentConfiguration = contentConfig

        return cell
    }

    // MARK: - Extra Functions
    private func setupButtonsOfNavigationItem() {
        // button: add item
        let addNewItemButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddItemButtonTapped))
        
        // button: share item list
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareItemList))
        
        navigationItem.rightBarButtonItems = [shareButton, addNewItemButton]

        // button: reset item list
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetItemList))
    }
    
    @objc private func shareItemList() {
        let stringOfItemList = itemList.joined(separator: "\n")
        let av = UIActivityViewController(activityItems: [stringOfItemList], applicationActivities: nil)
        present(av, animated: true, completion: nil)
    }

    @objc private func handleAddItemButtonTapped() {
        let ac = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)

        //ac.addTextField()
        ac.addTextField { textField in
            textField.placeholder = "input new Item's name here"
        }
        
        let actionAddNewItem = UIAlertAction(title: "Add", style: .default) { [weak ac, weak self] _ in
            guard let inputValue = ac?.textFields?[0].text else { return }
            self?.addItem(itemName: inputValue)
        }
        ac.addAction(actionAddNewItem)

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(ac, animated: true, completion: nil)
    }

    @objc private func resetItemList() {
        itemList.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    private func showAlertOfError(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))

        present(ac, animated: true, completion: nil)
    }

    private func addItem(itemName: String) {
        if !itemName.isEmpty {
            if !itemList.contains(itemName) {
                itemList.insert(itemName, at: 0)

                let indexPathOfFirstRow = IndexPath(row: 0, section: 0)
                tableView.insertRows(at: [indexPathOfFirstRow], with: .automatic)

            } else {
                showAlertOfError(errorTitle: "Invalid Item", errorMessage: "Item is already in list")
            }
        } else {
            showAlertOfError(errorTitle: "Invalid Item", errorMessage: "Item's name must not empty")
        }
    }

}
