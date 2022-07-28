//
//  FlagDetailViewController.swift
//  MilestoneProject1To3
//
//  Created by Pham Anh Tuan on 7/28/22.
//

import UIKit

class FlagDetailViewController: UIViewController {
    @IBOutlet weak var flagImage: UIImageView!
    var selectedFlagName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showSelectedFlag()
    }
    
    private func showSelectedFlag() {
        let url = Bundle.main.bundleURL
        let flagFolderPath = url.appendingPathComponent("Flags", isDirectory: true)
        let finalPath = flagFolderPath.appendingPathComponent(selectedFlagName, isDirectory: false).path
        
        flagImage.image = UIImage(contentsOfFile: finalPath)
    }
}
