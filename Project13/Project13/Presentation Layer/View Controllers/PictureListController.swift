//
//  PictureListController.swift
//  Project13
//
//  Created by Pham Anh Tuan on 8/11/22.
//

import UIKit

/// <#Description#>
class PictureListController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let reuseIdentifier = "PictureCell"
    private var pictures = [Picture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddNewPicture))
        
        loadPictures()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let picture = pictures[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = picture.caption
        contentConfig.textProperties.font = UIFont.systemFont(ofSize: 30)
        cell.contentConfiguration = contentConfig
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewPictureDetailScreen(indexPath: indexPath)
    }
    
    // MARK: - Image Picker Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let picture = info[.editedImage] as? UIImage else { return }
        
        let pictureName = UUID().uuidString
        let picturePath = getDocumentDirectory().appendingPathComponent(pictureName)
        
        let pictureData = picture.jpegData(compressionQuality: 0.8)

        dismiss(animated: true)

        if FileManager.default.createFile(atPath: picturePath.path, contents: pictureData) {
            createNewPicture(name: pictureName)
        }
    }
    
    // MARK: - Action Handlers
    @objc private func handleAddNewPicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        
        present(imagePicker, animated: true)
    }
    
    private func viewPictureDetailScreen(indexPath index: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pictureDetailController = mainStoryboard.instantiateViewController(withIdentifier: "PictureDetail") as? PictureDetailController else { return }
        
        let selectedPictureName = pictures[index.row].fileName
        pictureDetailController.picturePath = getDocumentDirectory().appendingPathComponent(selectedPictureName).path
        
        navigationController?.pushViewController(pictureDetailController, animated: true)
    }
    
    // MARK: - Extra Functions
    private func getDocumentDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
    private func savePictures() {
        guard let data = try? JSONEncoder().encode(pictures) else { return }
        
        UserDefaults.standard.set(data, forKey: "Pictures")
    }
    
    private func loadPictures() {
        guard
            let data = UserDefaults.standard.object(forKey: "Pictures") as? Data,
            let tmpPictures = try? JSONDecoder().decode([Picture].self, from: data)
        else { return }
        
        pictures = tmpPictures
    }
    
    private func createNewPicture(name: String) {
        let newPic = Picture()
        newPic.fileName = name
        
        showAddAlertToSetCaptionOfPicture(newPic)
    }
    
    private func showAddAlertToSetCaptionOfPicture(_ picture: Picture) {
        let ac = UIAlertController(title: "Set Caption...", message: "Set caption of picture", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Set", style: .default, handler: { [weak self, weak ac] _ in
            guard let inputtedText = ac?.textFields?[0].text else { return }
            self?.addNewPictureWithCaption(picture, caption: inputtedText)
        }))
        
        present(ac, animated: true)
    }
    
    private func addNewPictureWithCaption(_ picture: Picture, caption: String) {
        picture.caption = caption
        pictures.insert(picture, at: 0)
        
        let indexOfFirstRowFirstSection = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexOfFirstRowFirstSection], with: .automatic)
        
        savePictures()
    }
}
