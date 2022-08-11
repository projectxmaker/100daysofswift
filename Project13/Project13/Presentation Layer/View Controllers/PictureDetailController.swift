//
//  PictureDetailController.swift
//  Project13
//
//  Created by Pham Anh Tuan on 8/11/22.
//

import UIKit

class PictureDetailController: UIViewController {

    @IBOutlet weak var pictureView: UIImageView!
    
    var picturePath = ""
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadPicture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideBarOnTapped(isBool: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideBarOnTapped(isBool: false)
    }
    
    // MARK: - Extra Functions
    private func loadPicture() {
        pictureView.image = UIImage(contentsOfFile: picturePath)
    }

    private func hideBarOnTapped(isBool: Bool) {
        navigationController?.hidesBarsOnTap = isBool
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
