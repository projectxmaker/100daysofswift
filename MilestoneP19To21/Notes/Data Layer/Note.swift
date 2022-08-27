//
//  Note.swift
//  Notes
//
//  Created by Pham Anh Tuan on 8/27/22.
//

import Foundation

struct Note: Codable {
    var title: String
    var text: String
    var createdAt: Date
    var updatedAt: Date
}
