//
//  Script.swift
//  Extension
//
//  Created by Pham Anh Tuan on 8/21/22.
//

import Foundation

class Script: Codable {
    var name: String
    var code: String
    
    init() {
        name = ""
        code = ""
    }
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
}
