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
    
    var topText: String = ""
    var topTextFontSize: CGFloat = 30
    var topTextXPosition: CGFloat = 0
    var topTextYPosition: CGFloat = 0
    var topTextColor = UIColor.gray
    
    var bottomText: String = ""
    var bottomTextFontSize: CGFloat = 30
    var bottomTextXPosition: CGFloat = 0
    var bottomTextYPosition: CGFloat = 0
    var bottomTextColor = UIColor.gray
    
    var isBeingModifyingTextType = TextType.topText
    
    let movementPace: CGFloat = 10
    
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
            UIBarButtonItem(image: UIImage(systemName: "textformat.size"), style: .plain, target: self, action: #selector(changeFontSize)),
            UIBarButtonItem(image: UIImage(systemName: "paintpalette"), style: .plain, target: self, action: #selector(changeFontColor)),
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

        ac.addTextField { [weak self] textfield in
            textfield.placeholder = "Input Top Text"
            textfield.text = self?.topText
        }
        
        ac.addTextField { [weak self] textfield in
            textfield.placeholder = "Input Bottom Text"
            textfield.text = self?.bottomText
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
                
                let topAttributedString = createNSAttributedString(topText, fontSize: topTextFontSize, fontColor: topTextColor)
                let bottomAttributedString = createNSAttributedString(bottomText, fontSize: bottomTextFontSize, fontColor: bottomTextColor)
                
                topAttributedString.draw(in: CGRect(x: topTextXPosition, y: topTextYPosition, width: image.size.width, height: image.size.height))
                
                bottomAttributedString.draw(in: CGRect(x: bottomTextXPosition, y: bottomTextYPosition, width: image.size.width, height: image.size.width))
            }

            renderedImage = rendereredImage
            imageView.image = rendereredImage
        }
    }
    
    func createNSAttributedString(_ text: String, fontSize: CGFloat, fontColor: UIColor) -> NSAttributedString {
        guard let font = UIFont(name: "ChalkboardSE-Bold", size: fontSize) else {
            return NSAttributedString(string: text)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let backgroundColor = UIColor(cgColor: CGColor(gray: 1, alpha: 0.5))

        let attributes: [NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: fontColor,
            .backgroundColor: backgroundColor,
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
    
    @objc func changeFontSize() {
        var textPosition = "Bottom Text"
        var textFontSize = bottomTextFontSize
        if isBeingModifyingTextType == .topText {
            textPosition = "Top Text"
            textFontSize = topTextFontSize
        }
        
        let ac = UIAlertController(title: "Font Size", message: "Change font size of \(textPosition)", preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.text = textFontSize.formatted()
        }
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak ac] _ in
            guard
                let newStringFontSize = ac?.textFields?[0].text as? NSString
            else { return }
            
            let newFontSize = CGFloat(newStringFontSize.floatValue)
            self?.saveFontSize(newFontSize)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func saveFontSize(_ newFontSize: CGFloat) {
        if isBeingModifyingTextType == .topText {
            topTextFontSize = newFontSize
        } else {
            bottomTextFontSize = newFontSize
        }
        
        setupTextsOnMeme()
    }
    
    @objc func changeFontColor() {
        
        var textColor = bottomTextColor
        if isBeingModifyingTextType == .topText {
            textColor = topTextColor
        }
        
        let cp = UIColorPickerViewController()
        cp.selectedColor = textColor
        cp.supportsAlpha = true
        cp.delegate = self
        cp.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(cp, animated: true)
 
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
        if isBeingModifyingTextType == .topText {
            switch side {
            case .top:
                topTextYPosition -= movementPace
            case .bottom:
                topTextYPosition += movementPace
            case .left:
                topTextXPosition -= movementPace
            case .right:
                topTextXPosition += movementPace
            }
            
        } else {
            switch side {
            case .top:
                bottomTextYPosition -= movementPace
            case .bottom:
                bottomTextYPosition += movementPace
            case .left:
                bottomTextXPosition -= movementPace
            case .right:
                bottomTextXPosition += movementPace
            }
        }
        
        setupTextsOnMeme()
    }
    
    func initDefaultTextPositions() {
        guard let image = originalImage else { return }
        
        topTextXPosition = 0
        topTextYPosition = image.size.height * 10/100
        
        bottomTextXPosition = 0
        bottomTextYPosition = image.size.height * 70/100
        
        print("\(image.size.height) | \(imageView.frame.size.height)")
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
            
            initDefaultTextPositions()
            
            showInformToInputTexts()
        }
    }
}

// UIColorPickerController
extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        saveNewColor(color)
    }
    
    func saveNewColor(_ newColor: UIColor) {
        if isBeingModifyingTextType == .topText {
            topTextColor = newColor
        } else {
            bottomTextColor = newColor
        }

        setupTextsOnMeme()
    }
}
