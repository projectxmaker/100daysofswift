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
    
    enum TextType {
        case topText
        case bottomText
    }
    
    enum MoveType {
        case top
        case bottom
        case left
        case right
    }
    
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
    
    var originalImageName: String = ""
    
    var topTextFontSize: CGFloat = 30
    var topText: String = ""
    var bottomTextFontSzie: CGFloat = 30
    var bottomText: String = ""
    
    var isBeingModifyingTextType = TextType.topText
    
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
            UIBarButtonItem(image: UIImage(systemName: "repeat.circle"), style: .plain, target: self, action: #selector(switchBetweenOriginalAndRenderedVersion)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Bottom", style: .plain, target: self, action: #selector(changeTextType)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "minus.circle"), style: .plain, target: self, action: #selector(descreaseFontSize)),
            UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(increaseFontSize)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "chevron.left.circle"), style: .plain, target: self, action: #selector(moveTextToLeft)),
            UIBarButtonItem(image: UIImage(systemName: "chevron.up.circle"), style: .plain, target: self, action: #selector(moveTextToTop)),
            UIBarButtonItem(image: UIImage(systemName: "chevron.down.circle"), style: .plain, target: self, action: #selector(moveTextToBottom)),
            UIBarButtonItem(image: UIImage(systemName: "chevron.right.circle"), style: .plain, target: self, action: #selector(moveTextToRight)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "pencil.circle"), style: .plain, target: self, action: #selector(showInformToInputTexts))
        ]
    }
    
    @objc func changeTextType(button: UIBarButtonItem) {
        if isBeingModifyingTextType == .bottomText {
            button.title = "Bottom"
            isBeingModifyingTextType = .topText
        } else {
            button.title = "Top"
            isBeingModifyingTextType = .bottomText
        }
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
    
    @objc func showInformToInputTexts() {
        let ac = UIAlertController(title: "Setup Texts On Meme ", message: nil, preferredStyle: .alert)

        ac.addTextField { textfield in
            textfield.placeholder = "Input Top Text"
        }
        
        ac.addTextField { textfield in
            textfield.placeholder = "Input Bottom Text"
        }

        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak ac, weak self] _ in
            guard
                let topText = ac?.textFields?[0].text,
                let bottomText = ac?.textFields?[1].text
            else {
                return
            }
            
            self?.topText = topText
            self?.bottomText = bottomText
            
            self?.setupTextsOnMeme()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func setupTextsOnMeme() {
        guard
            let image = originalImage
        else { return }
        
        if !topText.isEmpty || !bottomText.isEmpty {
            let renderer = UIGraphicsImageRenderer(size: image.size)
            
            let rendereredImage = renderer.image { ctx in
                image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                
                let topAttributedString = createNSAttributedString(topText, fontSize: topTextFontSize)
                let bottomAttributedString = createNSAttributedString(bottomText, fontSize: bottomTextFontSzie)
                
                topAttributedString.draw(in: CGRect(x: 0, y: 30, width: image.size.width, height: 150))
                
                bottomAttributedString.draw(in: CGRect(x: 0, y: image.size.height - 100, width: image.size.width, height: 100))
            }

            renderedImage = rendereredImage
            imageView.image = rendereredImage
        }
    }
    
    func createNSAttributedString(_ text: String, fontSize: CGFloat) -> NSAttributedString {
        guard let font = UIFont(name: "ChalkboardSE-Bold", size: fontSize) else {
            return NSAttributedString(string: text)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: UIColor.yellow,
            .backgroundColor: UIColor.gray,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    @objc func shareAPicture() {
        if let url = generateSharedFile() {
            let items: [URL] = [url]
            
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            
            present(ac, animated: true)
        }
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
    
    func generateSharedFile() -> URL? {
        guard
            let image = imageView.image,
            let imageData = image.pngData()
        else { return nil }
        
        let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(originalImageName)
                .appendingPathExtension("png")
        
        do {
            try imageData.write(to: url)
        } catch {
            let ac = UIAlertController(title: "Error", message: "Cannot share this picture", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Got it!", style: .cancel))
            
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(ac, animated: true)
            
            return nil
        }
        
        return url
    }
    
    @objc func increaseFontSize() {
        if isBeingModifyingTextType == .topText {
            topTextFontSize += 1
        } else {
            bottomTextFontSzie += 1
        }
        
        setupTextsOnMeme()
    }
    
    @objc func descreaseFontSize() {
        if isBeingModifyingTextType == .topText {
            topTextFontSize -= 1
        } else {
            bottomTextFontSzie -= 1
        }

        setupTextsOnMeme()
    }
    
    @objc func moveTextToTop() {
        moveText(.top)
    }
    
    @objc func moveTextToBottom() {
        moveText(.bottom)
    }
    
    @objc func moveTextToLeft() {
        moveText(.left)
    }
    
    @objc func moveTextToRight() {
        moveText(.right)
    }
    
    func moveText(_ side: MoveType) {
        #warning("code to move text here")
        if isBeingModifyingTextType == .topText {
            topTextFontSize -= 1
        } else {
            bottomTextFontSzie -= 1
        }
        
        setupTextsOnMeme()
    }
}

// PHPicker Delegate
extension ViewController: PHPickerViewControllerDelegate {
    
    // MARK: - PHPickerViewController Delegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if results.count > 0 {
            for eachResult in results {
                let itemProvider = eachResult.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        guard let fileName = itemProvider.suggestedName else { return }
                        self?.originalImageName = fileName
                        
                        DispatchQueue.main.async {
                            self?.showOnImageView(image: image, error: error)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func chooseAPicture(action: UIAlertAction) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        let newFilter = PHPickerFilter.images
        
        config.filter = newFilter
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.selectionLimit = 1

        let photoPicker = PHPickerViewController(configuration: config)
        photoPicker.delegate = self
        
        photoPicker.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(photoPicker, animated: true)
    }
    
    @objc private func showOnImageView(image: NSItemProviderReading?, error: Error? = nil) {
        if let image = image as? UIImage {
            originalImage = image
            imageView.image = image
            
            showInformToInputTexts()
        }
    }
}
