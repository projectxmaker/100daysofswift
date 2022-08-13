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
    @IBOutlet weak var radius: UISlider!
    @IBOutlet weak var scale: UISlider!
    @IBOutlet weak var buttonChangeFilter: UIButton!
    
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
        
        setupFilterSystem()
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
    
    @IBAction private func radiusChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction private func scaleChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction private func handleChangeFilterButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Change Filter", message: nil, preferredStyle: .alert)
        
        for eachFilterName in filterList {
            ac.addAction(UIAlertAction(title: eachFilterName, style: .default, handler: handleFilterOptionTapped))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @IBAction private func handleSaveButtonTapped(_ sender: Any) {
        guard let imageToBeSaved = imageView.image else {
            let ac = UIAlertController(title: "No Image To Save!", message: "There is no Image to be saved!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Got It!", style: .cancel))

            present(ac, animated: true)

            return
        }

        UIImageWriteToSavedPhotosAlbum(imageToBeSaved, self, #selector(handleResultOfSavingImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // MARK: - Extra Functions
    private func handleFilterOptionTapped(action: UIAlertAction) {
        // ensure there is an image ready to be filtered, and a filter is selected
        guard
            let filterName = action.title
        else { return}
        
        setFilter(filterName: filterName)
    }
    
    private func setFilter(filterName: String) {
        currentFilter = CIFilter(name: filterName)
        
        setTitleForChangeFilterButton(title: filterName)
        setupSliderVisibility()
        
        if currentImage != nil {
            setCurrentImageToCurrentFilter()
        }
    }
    
    private func applyProcessing() {
        if supportIntensitySlider() {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if supportRadiusSlider() {
            currentFilter.setValue(radius.value, forKey: kCIInputRadiusKey)
        }
        
        if supportScaleSlider() {
            currentFilter.setValue(scale.value, forKey: kCIInputScaleKey)
        }
        
        if supportCenterKey() {
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
    
    private func setTitleForChangeFilterButton(title: String) {
        buttonChangeFilter.setTitle(title, for: .normal)
    }
    
    private func supportIntensitySlider() -> Bool {
        currentFilter.inputKeys.contains(kCIInputIntensityKey)
    }
    
    private func supportRadiusSlider() -> Bool {
        currentFilter.inputKeys.contains(kCIInputRadiusKey)
    }
    
    private func supportScaleSlider() -> Bool {
        currentFilter.inputKeys.contains(kCIInputScaleKey)
    }
    
    private func supportCenterKey() -> Bool {
        currentFilter.inputKeys.contains(kCIInputCenterKey)
    }
    
    private func setupSliderVisibility() {
        enableSlider(intensity, isEnabled: supportIntensitySlider())
        enableSlider(radius, isEnabled: supportRadiusSlider())
        enableSlider(scale, isEnabled: supportScaleSlider())
    }
    
    private func setupFilterSystem() {
        context = CIContext()
        
        setFilter(filterName: filterList[0])
    }
    
    private func enableSlider(_ slider: UISlider, isEnabled: Bool) {
        slider.isSelected = isEnabled
        slider.isEnabled = isEnabled
    }
}

