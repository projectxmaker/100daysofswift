//
//  ViewController.swift
//  test
//
//  Created by Pham Anh Tuan on 8/3/22.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButtonTapped))
    }
    
    @objc private func handleAddButtonTapped() {
        let av = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        av.addTextField()
        av.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(av, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        
        return cell
    }
}

