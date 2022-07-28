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
        setupShareButton()
    }
    
    private func showSelectedFlag() {
        let url = Bundle.main.bundleURL
        let flagFolderPath = url.appendingPathComponent("Flags", isDirectory: true)
        let finalPath = flagFolderPath.appendingPathComponent(selectedFlagName, isDirectory: false).path
        
        flagImage.image = UIImage(contentsOfFile: finalPath)
    }
    
    // MARK: - Share Button
    private func setupShareButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleShareButtonTapped))
    }
    
    @objc private func handleShareButtonTapped() {
        let countryName = selectedFlagName.split(separator: "@", maxSplits: 2, omittingEmptySubsequences: true)[0]
        
        guard let image = flagImage.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        var activityItems: [Any] = []
        activityItems.append(image)
        activityItems.append(countryName)
        let av = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        present(av, animated: true, completion: nil)
    }
}
