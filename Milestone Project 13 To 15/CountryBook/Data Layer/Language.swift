//
//  Language.swift
//  CountryBook
//
//  Created by Pham Anh Tuan on 8/16/22.
//

import Foundation

// MARK: - Language
class Language: Codable, CountryDetail {
    var iso639_1, iso639_2, name, nativeName: String

    init(iso639_1: String, iso639_2: String, name: String, nativeName: String) {
        self.iso639_1 = iso639_1
        self.iso639_2 = iso639_2
        self.name = name
        self.nativeName = nativeName
    }
    
    func description() -> String {
        var info = [String]()
        
        info.append("- iso639_1: \(iso639_1)")
        info.append("- iso639_2: \(iso639_2)")
        info.append("- name: \(name)")
        info.append("- nativeName: \(nativeName)")
        
        return info.joined(separator: "\n")
    }
}
