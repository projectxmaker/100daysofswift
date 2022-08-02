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
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 25)
        cell.contentConfiguration = contentConfig

        return cell
    }
    
    // MARK: - Extra Functions
    private func setupButtonsOfNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddItemButtonTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetItemList))
    }
    
    @objc private func handleAddItemButtonTapped() {
        let av = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        av.addTextField()
        av.addAction(UIAlertAction(title: "Add", style: .default, handler: {[weak av, weak self] _ in
            let inputValue: String
            if let tempInputValue = av?.textFields?[0].text {
                if let itemExist = self?.itemList.contains(tempInputValue),
                   itemExist == false {
                    inputValue = tempInputValue
                    
                    self?.itemList.insert(inputValue, at: 0)
                        
                    let indexPathOfFirstRow = IndexPath(row: 0, section: 0)
                    self?.tableView.insertRows(at: [indexPathOfFirstRow], with: .automatic)
                    
                } else {
                    let av = UIAlertController(title: "Invalid Item", message: "Item's name must not empty", preferredStyle: .alert)
                    av.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
                    
                    self?.present(av, animated: true, completion: nil)
                }
            } else {
                let av = UIAlertController(title: "Invalid Item", message: "Item's name must not empty", preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
                
                self?.present(av, animated: true, completion: nil)
            }
        }))
                
        av.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(av, animated: true, completion: nil)
    }
    
    @objc private func resetItemList() {
        itemList.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

}
