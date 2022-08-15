//
//  ViewController.swift
//  Project2
//
//  Created by Pham Anh Tuan on 7/24/22.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    // MARK: - Constants
    struct keys {
        static let defaultScore = 0
        static let defaultCurrentQuestionNumber = 1
    }
    
    // MARK: - Variables
    var countries: [String] = []
    
    var score = ViewController.keys.defaultScore
    var correctAnswer = 0
    let totalOfQuestions = 10
    var currentQuestionNumber = ViewController.keys.defaultCurrentQuestionNumber
    
    var highScore = 0
    var congratNewHighScore = false
    
    // MARK: - Table View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        resetDefaultStats()
        setupCountries()
        decorateAllFlags()
        setupFlags()
        setupButtonToShowScore()
        loadPreviousHighScore()
    }
    
    // MARK: - Extra Functions
    
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
    
    private func flagTapped(_ sender: UIButton) {
        bounceTheButton(sender, nextAction: evaluteAnswer)
    }
    
    private func evaluteAnswer(_ sender: UIButton) {
        let selectedAnswer = sender.tag
        if selectedAnswer == correctAnswer {
            score += 1
            beforeMoveToNextQuestion()
        } else {
            score -= 1
            
            let ac = UIAlertController(title: "Wrong Answer", message: "That’s the flag of \(countries[selectedAnswer].uppercased())", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: beforeMoveToNextQuestion))
            present(ac, animated: true, completion: nil)
        }
        
        saveHighScore()
    }
    
    private func saveHighScore() {
        if highScore == 0 || highScore < score {
            let defaultData = UserDefaults.standard
            defaultData.set(score, forKey: "PreviousHighScore")
            
            if !congratNewHighScore {
                congratNewHighScore = true
                
                let ac = UIAlertController(title: "Congrats", message: "You reached \(score), a new highest score!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                present(ac, animated: true)
            }
        }
    }
    
    private func loadPreviousHighScore() {
        let defaultData = UserDefaults.standard
        highScore = defaultData.integer(forKey: "PreviousHighScore")
    }
    
    private func beforeMoveToNextQuestion(_ action: UIAlertAction? = nil) {
        if currentQuestionNumber > totalOfQuestions {
            let ac = UIAlertController(title: "Final Score", message: "Your score \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: setupFlags))
            
            present(ac, animated: true, completion: nil)
            
            resetDefaultStats()
        } else {
            setupFlags()
        }
    }
    
    private func setupButtonToShowScore() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleButtonShowScoreInfoTapped))
    }
    
    @objc private func handleButtonShowScoreInfoTapped() {
        let ac = UIAlertController(title: "Score", message: "Your current score \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func bounceTheButton(_ sender: UIButton, nextAction: @escaping (UIButton) -> Void) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 3, options: []) {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            sender.transform = CGAffineTransform.identity
            nextAction(sender)
        }
    }
    
    // MARK: - IBAction
    @IBAction func buttonTapped(_ sender: UIButton) {
        currentQuestionNumber += 1
        flagTapped(sender)
    }
}

