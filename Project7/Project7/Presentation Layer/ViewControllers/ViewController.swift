//
//  ViewController.swift
//  Project7
//
//  Created by Pham Anh Tuan on 8/4/22.
//

import UIKit

class ViewController: UITableViewController {

    private var petitions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = "Title"
        contentConfig.secondaryText = "Subtitle"
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 30)
        contentConfig.secondaryTextProperties.font = UIFont.systemFont(ofSize: 20)
        
        cell.contentConfiguration = contentConfig
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

