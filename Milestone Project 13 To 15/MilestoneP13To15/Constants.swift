//
//  Constants.swift
//  MilestoneP13To15
//
//  Created by Pham Anh Tuan on 8/16/22.
//

import Foundation

extension CountryListControllerTableViewController {
    struct keys {
        static let countryListAPIUrl = "https://restcountries.com/v2/all?fields=name,alpha3Code"
        static let countryCellIdentifier = "CountryCell"
        
    }
}

extension CountryDetailViewController {
    struct keys {
        static let countryDetailAPIUrl = "https://restcountries.com/v2/alpha/"
        static let countryDetailIdentifier = "CountryDetail"
        static let countryDetailCellIdentifier = "DetailCell"
    }
}
