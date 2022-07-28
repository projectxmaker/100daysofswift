//
//  ViewController.swift
//  MilestoneProject1To3
//
//  Created by Pham Anh Tuan on 7/28/22.
//

import UIKit

class FlagListViewController: UITableViewController {

    private var flagList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareFlagList()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flagList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell") else {
            return UITableViewCell() }
        
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = flagList[indexPath.row]
        contentConfiguration.textProperties.font = UIFont.systemFont(ofSize: 20)
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }

    private func prepareFlagList() {
        let filePaths: [String]
        
        let url = Bundle.main.bundleURL
        let flagFolderPath = url.appendingPathComponent("Flags", isDirectory: true)
        
        let fm = FileManager.default
        
        do {
            filePaths = try fm.contentsOfDirectory(atPath: flagFolderPath.path)
        }
        catch {
            filePaths = []
        }
        
        for filePath in filePaths {
            flagList.append(filePath)
        }
    }
}

