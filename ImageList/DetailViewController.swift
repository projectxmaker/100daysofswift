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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedImage
        
        navigationItem.largeTitleDisplayMode = .never
        
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
}
