//
//  ViewController.swift
//  ImageList
//
//  Created by Pham Anh Tuan on 7/23/22.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage: String?
    var pageTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = pageTitle
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleRightBarButtonTapped))
        
        showImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        hideNavigationBar(false)
    }
    
    private func hideNavigationBar(_ isVisible: Bool = true) {
        navigationController?.hidesBarsOnTap = isVisible
    }
    
    private func showImage() {
        guard let loadedImage = selectedImage else { return }
        imageView.image = UIImage(imageLiteralResourceName: loadedImage)
    }
    
    // MARK: - Navigation Bar
    @objc private func handleRightBarButtonTapped() {
        guard
            let image = imageView.image?.jpegData(compressionQuality: 0.8)
        else { return }
        
        let av = UIActivityViewController(activityItems: [image], applicationActivities: [])
        
        av.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

        present(av, animated: true, completion: nil)
    }
}
