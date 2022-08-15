//
//  Country.swift
//  MilestoneP13To15
//
//  Created by Pham Anh Tuan on 8/15/22.
//

import Foundation

// MARK: - Country
class Country: Codable {
    var name: String
    var topLevelDomain: [String]?
    var alpha2Code, alpha3Code: String?
    var callingCodes: [String]?
    var capital: String?
    var altSpellings: [String]?
    var subregion, region: String?
    var population: Int?
    var latlng: [Double]?
    var demonym: String?
    var area: Double?
    var timezones, borders: [String]?
    var nativeName, numericCode: String?
    var flag: String?
    var cioc: String?
    var independent: Bool?
}

