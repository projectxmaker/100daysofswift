//
//  Person.swift
//  Project10
//
//  Created by Pham Anh Tuan on 8/8/22.
//

import UIKit

class Person: NSObject {
    var name: String
    var imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}
