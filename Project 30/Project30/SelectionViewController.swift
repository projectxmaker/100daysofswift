//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

		// load all the JPEGs into our array
		let fm = FileManager.default

        if let resourcePath = Bundle.main.resourcePath {
            if let tempItems = try? fm.contentsOfDirectory(atPath: resourcePath) {
                for item in tempItems {
                    if item.range(of: "Large") != nil {
                        if let cachedImageName = cacheImage(item) {
                            items.append(cachedImageName)
                        }
                    }
                }
            }
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		// find the image for this cell, and load its thumbnail
		let currentImageName = items[indexPath.row % items.count]
        guard let currentImage = getImageByImageName(currentImageName) else { return UITableViewCell() }
        
        cell.imageView?.image = currentImage

		// give the images a nice shadow to make them look a bit more dramatic
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
        cell.textLabel?.text = "\(defaults.integer(forKey: currentImageName))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
        let imageName = items[indexPath.row % items.count]
		vc.imageTitle = imageName
        vc.image = getImageByImageName(imageName)
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

		// add to our view controller cache and show
        guard let navigationController = navigationController else { return }
		navigationController.pushViewController(vc, animated: true)
	}
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func cacheImage(_ imageName: String) -> String? {
        // find the image for this cell, and load its thumbnail
        let imageRootName = imageName.replacingOccurrences(of: "Large", with: "Thumb")
        
        if let _ = getImageByImageName(imageRootName) {
            return imageRootName
        }
        
        guard
            let path = Bundle.main.path(forResource: imageRootName, ofType: nil),
            let original = UIImage(contentsOfFile: path)
        else {
            return nil
        }

        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)

        let rounded = renderer.image { ctx in
            ctx.cgContext.addEllipse(in: renderRect)
            ctx.cgContext.clip()

            original.draw(in: renderRect)
        }

        // save to app's document directory
        let cachedImageUrl = getImagePathInDocumentDirectory(imageRootName)
        
        if let data = rounded.pngData() {
            try? data.write(to: cachedImageUrl)
        }
        
        return imageRootName
    }
    
    func getImagePathInDocumentDirectory(_ imageName: String) -> URL {
        let appDocumentDirectoryPath = getDocumentsDirectory()
        return appDocumentDirectoryPath.appendingPathComponent(imageName)
    }
    
    func getImageByImageName(_ imageName: String) -> UIImage? {
        let currentImagePath = getImagePathInDocumentDirectory(imageName).path
        
        return UIImage(contentsOfFile: currentImagePath)
    }
}
