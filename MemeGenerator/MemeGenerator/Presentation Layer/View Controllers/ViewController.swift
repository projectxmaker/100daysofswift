//
//  ViewController.swift
//  MemeGenerator
//
//  Created by Pham Anh Tuan on 9/8/22.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var originalImage: UIImage? {
        didSet {
            imageViewWithOriginalImage = true
            hideToolbars(false)
        }
    }
    
    var renderedImage: UIImage? {
        didSet {
            imageViewWithOriginalImage = false
        }
    }
    
    var imageViewWithOriginalImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupNavigationItems()
        
        showInformToSelectAPicture()
    }

    // MARK: - Extra Funcs
    func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(chooseAPicture))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAPicture))

        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(switchBetweenOriginalAndRenderedVersion)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showInformToInputTexts))
        ]
    }
    
    func hideToolbars(_ hide: Bool) {
        navigationController?.isToolbarHidden = hide
    }
    
    func showInformToSelectAPicture() {
        let ac = UIAlertController(title: "Create A Meme", message: "Choose a picture", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Choose", style: .default, handler: chooseAPicture))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    @objc func chooseAPicture(action: UIAlertAction) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        imagePicker.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(imagePicker, animated: true)
    }
    
    @objc func showInformToInputTexts() {
        let ac = UIAlertController(title: "Setup Texts On Meme ", message: nil, preferredStyle: .alert)

        ac.addTextField { textfield in
            textfield.placeholder = "Input text laid at the top of the picture"
        }
        
        ac.addTextField { textfield in
            textfield.placeholder = "Input text laid at the bottom of the picture"
        }

        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak ac, weak self] _ in
            let topText = ac?.textFields?[0].text
            let bottomText = ac?.textFields?[1].text
            
            self?.setupTextsOnMeme(topText: topText, bottomText: bottomText)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func setupTextsOnMeme(topText: String?, bottomText: String?) {
        guard
            let image = originalImage,
            let topText = topText,
            let bottomText = bottomText
        else { return }
        
        if !topText.isEmpty || !bottomText.isEmpty {
            let renderer = UIGraphicsImageRenderer(size: image.size)
            
            let rendereredImage = renderer.image { ctx in
                image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                
                let topAttributedString = createNSAttributedString(topText)
                let bottomAttributedString = createNSAttributedString(bottomText)
                
                topAttributedString.draw(in: CGRect(x: 0, y: 30, width: image.size.width, height: 150))
                
                bottomAttributedString.draw(in: CGRect(x: 0, y: image.size.height - 100, width: image.size.width, height: 100))
            }

            renderedImage = rendereredImage
            imageView.image = rendereredImage
        }
    }
    
    func createNSAttributedString(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let font = UIFont(name: "ChalkboardSE-Bold", size: 50) ?? UIFont.systemFont(ofSize: 20)

        let attributes: [NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: UIColor.yellow,
            .backgroundColor: UIColor.gray,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    @objc func shareAPicture() {
        guard
            let image = imageView.image,
            let imageData = image.jpegData(compressionQuality: 0.8)
        else { return }
        
        let items: [Data] = [imageData]
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
    }
    
    @objc func switchBetweenOriginalAndRenderedVersion() {
        guard
            let renderedImage = renderedImage,
            let originalImage = originalImage
        else {
            return
        }
        
        if imageViewWithOriginalImage {
            imageView.image = renderedImage
            imageViewWithOriginalImage = false
        } else {
            imageView.image = originalImage
            imageViewWithOriginalImage = true
        }
    }
}

// ImagePickerController Delegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else { return }

        originalImage = image
        imageView.image = image
        
        showInformToInputTexts()
    }
}

