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
    var selectedFlagPath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showSelectedFlag()
        setupShareButton()
    }
    
    // MARK: - Share Button
    private func setupShareButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleShareButtonTapped))
    }
    
    @objc private func handleShareButtonTapped() {
        guard let image = flagImage.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        var activityItems: [Any] = []
        activityItems.append(image)
        activityItems.append(selectedFlagName)
        let av = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        present(av, animated: true, completion: nil)
    }
    
    private func showSelectedFlag() {
        flagImage.image = UIImage(contentsOfFile: selectedFlagPath)
    }
}
