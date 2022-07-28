//
//  ViewController.swift
//  MilestoneProject1To3
//
//  Created by Pham Anh Tuan on 7/28/22.
//

import UIKit

class FlagListViewController: UITableViewController {

    private var flagList: [String: String] = [:]
    private var flagNamesInOrder: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareFlagList()
    }

    // MARK: - Table Configuration
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flagList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell")
        else {
            return UITableViewCell() }
        
        var contentConfiguration = cell.defaultContentConfiguration()
        
        let flagName = flagNamesInOrder[indexPath.row]
        contentConfiguration.text = flagName
        contentConfiguration.textProperties.font = UIFont.systemFont(ofSize: 20)
        
        if let flagPath = flagList[flagName] {
            contentConfiguration.image = UIImage(contentsOfFile: flagPath)
        }
        
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let flagDetailViewController = storyboard.instantiateViewController(withIdentifier: "FlagDetail") as? FlagDetailViewController else { return }
        
        let flagFileName = flagNamesInOrder[indexPath.row]
        let flagFilePath = flagList[flagFileName] ?? ""
        flagDetailViewController.selectedFlagName = flagFileName
        flagDetailViewController.selectedFlagPath = flagFilePath
        
        navigationController?.pushViewController(flagDetailViewController, animated: true)
    }

    
    // MARK: - Functions
    private func prepareFlagList() {
        var addedFlags: [String] = []
        let fileNames: [String]
        var selectedFlags: [String:String] = [:]
        
        let url = Bundle.main.bundleURL
        let flagFolderPath = url.appendingPathComponent("Flags", isDirectory: true)
        
        let fm = FileManager.default
        
        do {
            fileNames = try fm.contentsOfDirectory(atPath: flagFolderPath.path)
        }
        catch {
            fileNames = []
        }
        
        for fileName in fileNames {
            // only filter 3X PNG files
            if fileName.hasSuffix("@3x.png") == true {
                let countryName = fileName.split(separator: "@", maxSplits: 2, omittingEmptySubsequences: true)[0].uppercased()
                
                if addedFlags.contains(countryName) == false {
                    addedFlags.append(countryName)
                    selectedFlags[countryName] = flagFolderPath.appendingPathComponent(fileName, isDirectory: false).path
                }
            }
        }
        
        if addedFlags.count > 0 {
            // sort by alphabet
            addedFlags.sort { a, b in
                a < b
            }
            
            for seletedFlagName in addedFlags {
                flagNamesInOrder.append(seletedFlagName)
                flagList[seletedFlagName] = selectedFlags[seletedFlagName]
            }
        }
    }
}

