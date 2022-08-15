//
//  CountryListControllerTableViewController.swift
//  MilestoneP13To15
//
//  Created by Pham Anh Tuan on 8/15/22.
//

import UIKit

class CountryListControllerTableViewController: UITableViewController {

    private var countries = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Country Book"
        
        performSelector(inBackground: #selector(getCountryData), with: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryListControllerTableViewController.keys.countryCellIdentifier, for: indexPath)

        let country = countries[indexPath.row]
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = country.name
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 30)
        cell.contentConfiguration = contentConfig

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = countries[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let countryAlpha3Code = country.alpha3Code,
            let countryDetailController = storyboard.instantiateViewController(withIdentifier: CountryDetailViewController.keys.countryDetailIdentifier) as? CountryDetailViewController else { return }
        
        countryDetailController.alpha3CodeOfSelectedCountry = countryAlpha3Code
        
        navigationController?.pushViewController(countryDetailController, animated: true)
    }
    
    // MARK: - Extra Function
    
    @objc private func getCountryData() {
        let countryListEndpoint = CountryListControllerTableViewController.keys.countryListAPIUrl
        guard
            let countryListUrl = URL(string: countryListEndpoint),
            let data = try? Data(contentsOf: countryListUrl),
            let decodedData = try? JSONDecoder().decode([Country].self, from: data)
        else { return }
        
        countries = decodedData
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

}
