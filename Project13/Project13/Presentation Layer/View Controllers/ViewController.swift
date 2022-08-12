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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleSelectImageFromPhotoButtonTapped))
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
    }
    
    // MARK: - Slider Functions
    private func intensityChanged() {
        
    }
    
    // MARK: - IB Actions
    @IBAction private func changeFilter(_ button: UIButton) {
        
    }
    
    @IBAction private func save(_ button: UIButton) {
        
    }
}

