//
//  Currency.swift
//  CountryBook
//
//  Created by Pham Anh Tuan on 8/16/22.
//

import Foundation

// MARK: - Currency
class Currency: Codable, CountryDetail {
    var code, name, symbol: String

    init(code: String, name: String, symbol: String) {
        self.code = code
        self.name = name
        self.symbol = symbol
    }
    
    func description() -> String {
        var info = [String]()
        
        info.append("- code: \(code)")
        info.append("- name: \(name)")
        info.append("- symbol: \(symbol)")
        
        return info.joined(separator: "\n")
    }
}
