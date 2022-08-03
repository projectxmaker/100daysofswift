//
//  ViewController.swift
//  test3
//
//  Created by Pham Anh Tuan on 8/3/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        view.addSubview(button)
        
        button.setTitle("Test", for: .normal)
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.center = view.center
        button.addTarget(self, action: #selector(presentAlertController), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    @objc func presentAlertController() {
        let alertController = UIAlertController(title: "Login",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addTextField()
        self.present(alertController,
                     animated: true)
    }
}

