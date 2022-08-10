//
//  CollectionViewController.swift
//  ImageList
//
//  Created by Pham Anh Tuan on 8/8/22.
//

import UIKit

private let reuseIdentifier = "Picture"

class CollectionViewController: UICollectionViewController {

    var pictures = [String?]()
    var pictureViews: [String:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image List"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        performSelector(inBackground: #selector(fetchImages), with: nil)
        setupNavigationController()
        loadPictureViews()
        print("viewDidLoad  ")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictures.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemIndex = indexPath.item
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PictureCellCollectionViewCell,
            let pictureName = pictures[itemIndex]
        else { return UICollectionViewCell() }
        
        // Configure the cell
        cell.pictureName.text = pictureName
        cell.views = getPictureViews(for: itemIndex)
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetailScreen(for: indexPath)
    }
    
    // MARK: - Extra Functions
    
    @objc private func fetchImages() {
        getImageList(with: "nssl")
        
        DispatchQueue.main.async {
            //self.tableView.reloadData()
        }
    }
    
    private func getImageList(with prefix: String) {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if item.hasPrefix(prefix) {
                pictures.append(item)
            }
        }
        
        sortImageList()
    }
    
    private func sortImageList() {
        pictures.sort { (a: String?, b: String?) in
            guard
                let lhs = a,
                let rhs = b
            else {
                return false
            }
            return lhs < rhs
        }
    }
    
    private func showDetailScreen(for indexPath: IndexPath) {
        let rowIndex = indexPath.item
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard
            let pictureName = pictures[rowIndex],
            let detailViewController = mainStoryboard.instantiateViewController(withIdentifier: "Detail") as? DetailViewController
        else
        { return }
        
        detailViewController.selectedImage = pictureName
        detailViewController.pageTitle = getTitleOfDetailScreen(at: rowIndex)
        
        // push DetailViewController to NavigationBar
        navigationController?.pushViewController(detailViewController, animated: true)
        
        increaseViewForSelectedPicture(for: indexPath)
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleSharedButtonTapped))
    }
    
    @objc private func handleSharedButtonTapped() {
        let appURL = "http://projectxmaker.com/imagelist"
        
        let av = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        av.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(av, animated: true, completion: nil)
    }
    
    private func getTitleOfDetailScreen(at picIndex: Int) -> String {
        "Picture \(picIndex + 1) of \(pictures.count)"
    }

    private func increaseViewForSelectedPicture(for indexPath: IndexPath) {
        let index = indexPath.item
        guard let pictureName = pictures[index] else { return }
        
        pictureViews[pictureName] = (pictureViews[pictureName] ?? 0) + 1
        
        updatePictureViewsOfSelectedPicture(for: indexPath)
        
        savePictureViews()
    }
    
    private func getPictureViews(for index: Int) -> Int {
        guard
            let pictureName = pictures[index],
            let pictureViews = pictureViews[pictureName]
        else { return 0 }
        
        return pictureViews
    }
    
    private func savePictureViews() {
        guard let data = try? JSONEncoder().encode(pictureViews) else { return }
        
        let defaultData = UserDefaults.standard
        defaultData.set(data, forKey: "PictureViews")
    }
    
    private func loadPictureViews() {
        let defaultData = UserDefaults.standard
        guard
            let data = defaultData.object(forKey: "PictureViews") as? Data,
            let tmpPictureViews = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return }
        
        pictureViews = tmpPictureViews
    }
    
    private func updatePictureViewsOfSelectedPicture(for indexPath: IndexPath) {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PictureCellCollectionViewCell,
            let pictureName = pictures[indexPath.item],
            let pictureViews = pictureViews[pictureName]
        else { return }

        cell.views = pictureViews
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
