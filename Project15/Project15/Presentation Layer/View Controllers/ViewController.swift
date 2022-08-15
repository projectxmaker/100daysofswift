//
//  ViewController.swift
//  Project15
//
//  Created by Pham Anh Tuan on 8/15/22.
//

import UIKit

class ViewController: UIViewController {

    private var switcherButton: UIButton!
    
    private var imageView: UIImageView!
    private var counter = 0
    private let totalOfAnimations = 7

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        // Do any additional setup after loading the view.
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        switcherButton = UIButton(configuration: .filled())
        switcherButton.translatesAutoresizingMaskIntoConstraints = false
        switcherButton.addTarget(self, action: #selector(handleSwitcherButtonTapped), for: .touchUpInside)
        switcherButton.setTitle("Animation Switcher", for: .normal)
        switcherButton.backgroundColor = .green
        view.addSubview(switcherButton)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0),
            imageView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor, constant: 0),

            switcherButton.heightAnchor.constraint(equalToConstant: 44),
            switcherButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.3),
            switcherButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            switcherButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
            
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    
    // MARK: - IB Action
    @objc private func handleSwitcherButtonTapped(_ button: UIButton) {
        button.isHidden = true
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: []) {
            switch self.counter {
            case 0:
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                break
                
            case 1:
                self.imageView.transform = CGAffineTransform.identity
                break
                
            case 2:
                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
                break
                
            case 3:
                self.imageView.transform = CGAffineTransform.identity
                break
                
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                break
                
            case 5:
                self.imageView.transform = CGAffineTransform.identity
                break
                
            case 6:
                self.imageView.alpha = 0.1
                self.imageView.backgroundColor = .green
                break
                
            case 7:
                self.imageView.alpha = 1
                self.imageView.backgroundColor = .clear
                break
                
                
            default:
                break
            }
        } completion: { finished in
            button.isHidden = false
        }

        counter += 1
        
        if counter > totalOfAnimations {
            counter = 0
        }
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
