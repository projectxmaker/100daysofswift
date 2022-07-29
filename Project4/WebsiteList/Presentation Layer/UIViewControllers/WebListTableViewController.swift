//
//  WebListTableViewController.swift
//  Project4
//
//  Created by Pham Anh Tuan on 7/29/22.
//

import UIKit

class WebListTableViewController: UITableViewController {

    private let websites = ["vnexpress.net", "zingnews.vn"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Website List"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return websites.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebCell", for: indexPath)

        let website = websites[indexPath.row]
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = website
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 20)
        cell.contentConfiguration = contentConfig
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let website = websites[indexPath.row]
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let webDetailViewController = storyboard.instantiateViewController(withIdentifier: "WebDetail") as? WebDetailViewController else { return }
        
        webDetailViewController.websites = websites
        webDetailViewController.defaultWebsite = website
        
        navigationController?.pushViewController(webDetailViewController, animated: true)
    }
}
