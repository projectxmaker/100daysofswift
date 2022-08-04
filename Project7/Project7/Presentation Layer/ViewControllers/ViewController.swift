//
//  ViewController.swift
//  Project7
//
//  Created by Pham Anh Tuan on 8/4/22.
//

import UIKit

class ViewController: UITableViewController {

    private var petitions = [Petition]()
    
    // MARK: - Override Functions Of TableViewControllers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPetitions()
        setupCreditsButton()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let cellData = petitions[indexPath.row]
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = cellData.title
        contentConfig.secondaryText = cellData.body
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 18)
        contentConfig.textProperties.numberOfLines = 1
        contentConfig.secondaryTextProperties.font = UIFont.systemFont(ofSize: 15)
        contentConfig.secondaryTextProperties.numberOfLines = 1
        
        cell.contentConfiguration = contentConfig
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailView = DetailViewController()
        detailView.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(detailView, animated: true)
    }
    
    // MARK: - Extra Functions
    private func getPetitions() {
        let mostRecentPetitionUrl = "https://www.hackingwithswift.com/samples/petitions-1.json"
        let topRatedPetitionUrl = "https://www.hackingwithswift.com/samples/petitions-2.json"
        
        let petitionUrl: String
        if navigationController?.tabBarItem.tag == 0 {
            petitionUrl = mostRecentPetitionUrl
        } else {
            petitionUrl = topRatedPetitionUrl
        }
        
        guard
            let url = URL(string: petitionUrl),
            let data = try? Data.init(contentsOf: url)
        else {
            showError()
            return
        }
        
        parse(from: data)
    }
    
    private func parse(from data: Data) {
        let decoder = JSONDecoder()
        
        guard let parsedData = try? decoder.decode(Petitions.self, from: data) else { return }
        
        petitions = parsedData.results
        tableView.reloadData()
    }
    
    private func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "Got error while loading the page", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func setupCreditsButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleCreditsButtonTapped))
    }
    
    @objc private func handleCreditsButtonTapped() {
        let ac = UIAlertController(title: "Credits", message: "The data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}

