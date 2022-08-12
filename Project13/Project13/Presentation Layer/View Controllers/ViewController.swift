//
//  ViewController.swift
//  Project13
//
//  Created by Pham Anh Tuan on 8/12/22.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    
    var currentImage: UIImage!
    
    private var context: CIContext!
    private var currentFilter: CIFilter!
    
    let filterList = [
        "CIBumpDistortion",
        "CIGaussianBlur",
        "CIPixellate",
        "CISepiaTone",
        "CITwirlDistortion",
        "CIUnsharpMask",
        "CIVignette"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleSelectImageFromPhotoButtonTapped))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    // MARK: - Button Functions
    @objc private func handleSelectImageFromPhotoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    // MARK: - Image Picker Controller Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        currentImage = image

        dismiss(animated: true)
        
        setCurrentImageToCurrentFilter()
    }
    
    // MARK: - IB Actions
    @IBAction private func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction private func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Change Filter", message: nil, preferredStyle: .alert)
        
        for eachFilterName in filterList {
            ac.addAction(UIAlertAction(title: eachFilterName, style: .default, handler: setFilter))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @IBAction private func save(_ sender: Any) {
        guard let imageToBeSaved = imageView.image else {
            let ac = UIAlertController(title: "No Image To Save!", message: "There is no Image to be saved!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Got It!", style: .cancel))
            
            present(ac, animated: true)
            
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(imageToBeSaved, self, #selector(handleResultOfSavingImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // MARK: - Extra Functions
    private func setFilter(action: UIAlertAction) {
        // ensure there is an image ready to be filtered, and a filter is selected
        guard
            currentImage != nil,
            let filterName = action.title
        else { return}
        
        currentFilter = CIFilter(name: filterName)
        
        setCurrentImageToCurrentFilter()
    }
    
    private func applyProcessing() {
        let supportedKeys = currentFilter.inputKeys
        
        if supportedKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if supportedKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if supportedKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if supportedKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        guard let image = currentFilter.outputImage else { return }
        
        guard let cgImage = context.createCGImage(image, from: image.extent) else { return }
        let newImage = UIImage(cgImage: cgImage)
        imageView.image = newImage
    }
    
    private func setCurrentImageToCurrentFilter() {
        guard let beginImage = CIImage(image: currentImage) else { return }
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

    //func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

    @objc private func handleResultOfSavingImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            let ac = UIAlertController(title: "Error!", message: "Saving image failed. It caused by \(error.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Got it!", style: .cancel))
            
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved Image Successfully!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Got it!", style: .cancel))
            
            present(ac, animated: true)
        }
    }
}

