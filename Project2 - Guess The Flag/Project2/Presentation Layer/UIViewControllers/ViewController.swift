//
//  ViewController.swift
//  Project2
//
//  Created by Pham Anh Tuan on 7/24/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    var countries: [String] = []
    var score = 0
    var correctAnswer = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCountries()
        decorateAllFlags()
        setupFlags()
    }
    
    private func setupCountries() {
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    }
    
    private func setupFlags(_ action: UIAlertAction? = nil) {
        countries.shuffle()
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        setupCorrectAnswer()
    }
    
    private func decorateAllFlags() {
        decorateFlag(button1)
        decorateFlag(button2)
        decorateFlag(button3)
    }
    
    private func decorateFlag(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupCorrectAnswer() {
        correctAnswer = Int.random(in: 0...2)
        let randomCorrectAnswer = countries[correctAnswer].uppercased()
        title = randomCorrectAnswer + " | Score: \(score)"
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title = ""
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Incorrect"
            score -= 1
        }
        
        let ac = UIAlertController(title: title, message: "Your score \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: setupFlags))
        
        present(ac, animated: true, completion: nil)
    }
}

