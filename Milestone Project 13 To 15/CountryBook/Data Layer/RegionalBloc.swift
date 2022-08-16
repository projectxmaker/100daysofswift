//
//  regionalBloc.swift
//  CountryBook
//
//  Created by Pham Anh Tuan on 8/16/22.
//

import Foundation

class RegionalBloc: Codable, CountryDetail {
    var acronym, name: String
    
    func description() -> String {
        var info = [String]()
        
        info.append("- acronym: \(acronym)")
        info.append("- name: \(name)")
        
        return info.joined(separator: "\n")
    }
}
