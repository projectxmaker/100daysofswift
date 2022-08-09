//
//  Person.swift
//  Project10
//
//  Created by Pham Anh Tuan on 8/8/22.
//

import UIKit

class Person: NSObject, NSCoding {
    var name: String
    var imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
    
    required init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        imageName = coder.decodeObject(forKey: "imageName") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(imageName, forKey: "imageName")
    }
}
