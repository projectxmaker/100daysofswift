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
        let image = UIImage(imageLiteralResourceName: loadedImage)
        
        imageView.image = renderImage(image)
    }
    
    private func renderImage(_ image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let renderedImage = renderer.image { cxt in
            image.draw(at: CGPoint(x: 0, y: 0))
            
            let string = "From Storm Viewer"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30),
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            attributedString.draw(with: CGRect(x: 0, y: 30, width: image.size.width, height: image.size.height), options: .usesLineFragmentOrigin, context: nil)
        }
        
        return renderedImage
    }
    
    // MARK: - Navigation Bar
    @objc private func handleRightBarButtonTapped() {
        guard
            let image = imageView.image?.jpegData(compressionQuality: 0.8)
        else { return }
        
        let imageName = selectedImage ?? ""
        let av = UIActivityViewController(activityItems: [image, imageName], applicationActivities: [])
        
        av.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

        present(av, animated: true, completion: nil)
    }
}
