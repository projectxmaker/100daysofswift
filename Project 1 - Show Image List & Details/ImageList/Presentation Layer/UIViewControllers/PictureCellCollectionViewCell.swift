//
//  PictureCellCollectionViewCell.swift
//  ImageList
//
//  Created by Pham Anh Tuan on 8/8/22.
//

import UIKit

class PictureCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pictureName: UILabel!
    @IBOutlet weak var pictureViews: UILabel!
    
    var views = 0 {
        didSet {
            pictureViews.text = "Views: \(views)"
        }
    }
}
