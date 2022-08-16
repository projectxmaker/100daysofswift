//
//  Capital.swift
//  Project16
//
//  Created by Pham Anh Tuan on 8/16/22.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var wikipediaUrl: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String, wikipediaUrl: String) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        self.wikipediaUrl = wikipediaUrl
    }
}
