//
//  ViewController.swift
//  test2
//
//  Created by Pham Anh Tuan on 8/3/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        handleAddButtonTapped()
    }
    
    @objc private func handleAddButtonTapped() {
        let av = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        av.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        av.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(av, animated: true, completion: nil)
    }

}

