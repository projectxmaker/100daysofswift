//
//  CountryDetailViewController.swift
//  MilestoneP13To15
//
//  Created by Pham Anh Tuan on 8/15/22.
//

import UIKit

class CountryDetailViewController: UITableViewController {

    var alpha3CodeOfSelectedCountry = ""
    var countryDetails = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(getCountryDataByAlpha3Code), with: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countryDetails.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryDetailViewController.keys.countryDetailCellIdentifier, for: indexPath)

        let detail = countryDetails[indexPath.row]
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = detail
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 20)
        cell.contentConfiguration = contentConfig

        return cell
    }

    // MARK: - Extra Function
    
    @objc private func getCountryDataByAlpha3Code() {
        let alpha3code = alpha3CodeOfSelectedCountry
        let countryDetailEndpoint = CountryDetailViewController.keys.countryDetailAPIUrl + alpha3code
        guard
            let countryDetailUrl = URL(string: countryDetailEndpoint),
            let data = try? Data(contentsOf: countryDetailUrl),
            let countryInfo = try? JSONDecoder().decode(Country.self, from: data)
        else { return }
        
        let mirror = Mirror(reflecting: countryInfo)
        
        for eachProperty in mirror.children {
            guard let infoTitle = eachProperty.label else {
                continue
            }
            
            var tmpInfoText = [String]()
            
            if let arrayValues = eachProperty.value as? [String] {
                for eachValue in arrayValues {
                    tmpInfoText.append(eachValue)
                }
            } else if let arrayValues = eachProperty.value as? [Int] {
                for eachValue in arrayValues {
                    tmpInfoText.append(eachValue.formatted())
                }
            } else if let arrayValues = eachProperty.value as? [Double] {
                for eachValue in arrayValues {
                    tmpInfoText.append(eachValue.formatted())
                }
            } else if let arrayCurrencies = eachProperty.value as? [CountryDetail] {
                tmpInfoText.append(getDescriptionOf(arrinfo: arrayCurrencies))
            } else if let valueOfBool = eachProperty.value as? Bool {
                tmpInfoText.append(valueOfBool ? "true" : "false")
            } else if let valueOfInt = eachProperty.value as? Int {
                tmpInfoText.append(valueOfInt.formatted())
            } else if let valueOfDouble = eachProperty.value as? Double {
                tmpInfoText.append(valueOfDouble.formatted())
            } else {
                tmpInfoText.append(eachProperty.value as? String ?? "")
            }
            
            let infoText = tmpInfoText.joined(separator: ", ")
            
            countryDetails.append("\(infoTitle): \(infoText)")
        }

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func getDescriptionOf(arrinfo: [CountryDetail]) -> String {
        var counter = 0
        var tempArrInfo = [String]()
        for eachInfo in arrinfo {
            if counter > 0 {
                tempArrInfo.append("---")
            } else {
                tempArrInfo.append("")
            }
            counter += 1
            
            tempArrInfo.append(eachInfo.description())
        }
        
        return tempArrInfo.joined(separator: "\n")
    }
}
