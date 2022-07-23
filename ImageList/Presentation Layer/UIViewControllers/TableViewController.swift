//
//  ViewController.swift
//  ImageList
//
//  Created by Pham Anh Tuan on 7/22/22.
//

import UIKit

class TableViewController: UITableViewController {
    var pictures = [String?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image List"
        
        getImageList(with: "nssl")
        setupNavigationController()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pictureName = pictures[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        var cellContentConfiguration = cell.defaultContentConfiguration()
        cellContentConfiguration.text = pictureName
        cell.contentConfiguration = cellContentConfiguration

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        showDetailScreen(for: indexPath.row)
    }
    
    private func getImageList(with prefix: String) {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if item.hasPrefix(prefix) {
                pictures.append(item)
            }
        }
    }
    
    private func showDetailScreen(for rowIndex: Int) {
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard
            let pictureName = pictures[rowIndex],
            let detailViewController = mainStoryboard.instantiateViewController(withIdentifier: "Detail") as? DetailViewController
        else
        { return }
        
        detailViewController.selectedImage = pictureName
        
        // push DetailViewController to NavigationBar
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}

