//
//  ViewController.swift
//  Project2
//
//  Created by Pham Anh Tuan on 7/24/22.
//

import UIKit

extension ViewController {

}

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    struct keys {
        static let defaultScore = 0
        static let defaultCurrentQuestionNumber = 1
    }
    
    var countries: [String] = []
    
    var score = ViewController.keys.defaultScore
    var correctAnswer = 0
    let totalOfQuestions = 10
    var currentQuestionNumber = ViewController.keys.defaultCurrentQuestionNumber
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        resetDefaultStats()
        setupCountries()
        decorateAllFlags()
        setupFlags()
    }
    
    private func resetDefaultStats() {
        score = ViewController.keys.defaultScore
        currentQuestionNumber = ViewController.keys.defaultCurrentQuestionNumber
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
        title = "\(randomCorrectAnswer) | \(currentQuestionNumber)/\(totalOfQuestions) | Score: \(score)"
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.tag == correctAnswer {
            score += 1
        } else {
            score -= 1
        }
        
        currentQuestionNumber += 1
        
        if currentQuestionNumber > totalOfQuestions {
            let ac = UIAlertController(title: "Final Score", message: "Your score \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: setupFlags))
            
            present(ac, animated: true, completion: nil)
            
            resetDefaultStats()
        } else {
            setupFlags()
        }
    }
}

