//
//  ViewController.swift
//  Project10
//
//  Created by Pham Anh Tuan on 8/7/22.
//

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var persons = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerNotifications()
        setupAddPersonButton()
        showAlertToAskForIdentification()
    }
    
    // MARK: - Collection View
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return persons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as? PersonCell else {
            // we failed to get a PersonCell – bail out!
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let person = persons[indexPath.item]
        let imagePath = getDocumentDirectory().appendingPathComponent(person.imageName).path
        cell.name.text = person.name
        
        cell.imageView.image = UIImage(contentsOfFile: imagePath)
        cell.imageView.layer.borderColor = UIColor.white.cgColor
        cell.imageView.layer.borderWidth = 1
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7

        // if we're still here it means we got a PersonCell, so we can return it
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemIndex = indexPath.item
        let ac = UIAlertController(title: "What do you want?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            self?.deletePerson(at: itemIndex)
        }))
        ac.addAction(UIAlertAction(title: "Update Name", style: .default, handler: { [weak self] _ in
            self?.showAlertToUpdatePersonName(at: itemIndex)
        }))
        
        present(ac, animated: true, completion: nil)
    }

    // MARK: - Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        let jpgImage = image.jpegData(compressionQuality: 0.8)
        
        do {
            try jpgImage?.write(to: imagePath)
            
            let person = Person(name: "Unknown", imageName: imageName)
            persons.insert(person, at: 0)
            
            let indexPathOfNewPerson = IndexPath(item: 0, section: 0)
            collectionView.insertItems(at: [indexPathOfNewPerson])
            
        } catch {
            let ac = UIAlertController(title: "Error", message: "Error while selecting the image.\n\(error.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            present(ac, animated: true, completion: nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Extra Functions
    private func setupAddPersonButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddPersonButtonTapped))
    }

    @objc private func handleAddPersonButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // allow to take picture from camera if this source type is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func showAlertToUpdatePersonName(at index: Int) {
        let ac = UIAlertController(title: "Update Name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            
            self?.updatePersonName(newName: newName, at: index)
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    private func updatePersonName(newName name: String, at index: Int) {
        let person = persons[index]
        person.name = name
        
        collectionView.reloadData()
    }
    
    private func deletePerson(at index: Int) {
        persons.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    private func getDocumentDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls)
        return urls[0]
    }
    
    // MARK: - Local Authentication
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(lockContent(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertToAskForIdentification), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func lockContent(_ notification: NSNotification) {
        collectionView.isHidden = true
    }
    
    @objc func showAlertToAskForIdentification() {
        let ac = UIAlertController(title: "Identify Yourself", message: "In order to see the content, please identify yourself.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Authenticate", style: .default, handler: { [weak self] _ in
            self?.authenticateWithBiometric()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func authenticateWithBiometric() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Identify yourself!", reply: { [weak self] isSuccess, error in
                    DispatchQueue.main.async {
                        if isSuccess {
                            self?.unlockContent()
                        } else {
                            let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                            self?.present(ac, animated: true)
                        }
                    }
                })
        } else {
            let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(ac, animated: true)
        }
    }
    
    func unlockContent() {
        collectionView.isHidden = false
    }
}

