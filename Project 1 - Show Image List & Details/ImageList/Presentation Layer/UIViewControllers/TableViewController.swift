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
        guard let pictureName = pictures[indexPath.row] else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        setupTitleOfRow(cell, with: pictureName)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        showDetailScreen(for: indexPath.row)
    }

    private func setupTitleOfRow(_ cell: UITableViewCell, with title: String) {
        var cellContentConfiguration = cell.defaultContentConfiguration()
        cellContentConfiguration.text = title
        cellContentConfiguration.textProperties.font = UIFont.systemFont(ofSize: 25)
        
        cell.contentConfiguration = cellContentConfiguration
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
        
        sortImageList()
    }
    
    private func sortImageList() {
        pictures.sort { (a: String?, b: String?) in
            guard
                let lhs = a,
                let rhs = b
            else {
                return false
            }
            return lhs < rhs
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
        detailViewController.pageTitle = getTitleOfDetailScreen(at: rowIndex)
        
        // push DetailViewController to NavigationBar
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleSharedButtonTapped))
    }
    
    @objc private func handleSharedButtonTapped() {
        let appURL = "http://projectxmaker.com/imagelist"
        
        let av = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        av.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(av, animated: true, completion: nil)
    }
    
    private func getTitleOfDetailScreen(at picIndex: Int) -> String {
        "Picture \(picIndex + 1) of \(pictures.count)" 
    }

}

