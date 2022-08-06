//
//  ViewController.swift
//  HangmanGame
//
//  Created by Pham Anh Tuan on 8/6/22.
//

import UIKit

class ViewController: UIViewController {

    private var scoreLabel: UILabel!
    private var clueLabel: UILabel!
    private var currentAnswerTextField: UITextField!
    private var currentAnswerButtons = [UIButton]()
    private var numberOfTriesLabel: UILabel!
    
    private var solutionInChars: [String] = []
    private var tappedCorrectChars: [String] = []
    private var clue: String = ""
    private var totalTried: Int = 0 {
        didSet {
            numberOfTriesLabel.text = "Number of tries: \(totalTried)/\(maximumTries)"
        }
    }
    private var arrData = [String]()
    
    private let maximumTries = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        performSelector(inBackground: #selector(fetchData), with: nil)
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .right
        view.addSubview(scoreLabel)
        
        clueLabel = UILabel()
        clueLabel.translatesAutoresizingMaskIntoConstraints = false
        clueLabel.textAlignment = .center
        clueLabel.text = "CLUE"
        clueLabel.font = UIFont.systemFont(ofSize: 20)
        clueLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(clueLabel)
        
        currentAnswerTextField = UITextField()
        currentAnswerTextField.translatesAutoresizingMaskIntoConstraints = false
        currentAnswerTextField.textAlignment = .center
        currentAnswerTextField.text = "HELLO"
        currentAnswerTextField.font = UIFont.systemFont(ofSize: 40)
        view.addSubview(currentAnswerTextField)
        
        numberOfTriesLabel = UILabel()
        numberOfTriesLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfTriesLabel.textAlignment = .center
        numberOfTriesLabel.text = "Number of tries: \(totalTried)/\(maximumTries)"
        view.addSubview(numberOfTriesLabel)
        
        let viewOfCharButtons = UIView()
        viewOfCharButtons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewOfCharButtons)

        var buttonConfigTint = UIButton.Configuration.tinted()
        buttonConfigTint.buttonSize = .large
        
        let charButtonWidth = 100
        let charButtonHeight = 44
        let buttonSpacing = 20
        
        let letters = (97...122).map({Character(UnicodeScalar($0))})
        
        var curCharIndex = 0
        for curRow in 0..<4 {
            for curCol in 0..<6 {
                let button = UIButton(configuration: buttonConfigTint, primaryAction: nil)
                
                var xAxis = curCol * charButtonWidth
                if curCol > 0 {
                    xAxis += curCol * buttonSpacing
                }
                
                button.frame = CGRect(x: xAxis, y: curRow * charButtonHeight * 2, width: charButtonWidth, height: charButtonHeight)
                button.setTitle(String(letters[curCharIndex]).capitalized, for: .normal)
                button.addTarget(self, action: #selector(handleCharButtonTapped(_:)), for: .touchUpInside)
                viewOfCharButtons.addSubview(button)
                
                curCharIndex += 1
            }
        }
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            clueLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            clueLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            clueLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: 0),
            
            currentAnswerTextField.topAnchor.constraint(equalTo: clueLabel.bottomAnchor, constant: 20),
            currentAnswerTextField.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            currentAnswerTextField.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: 0),
            
            numberOfTriesLabel.topAnchor.constraint(equalTo: currentAnswerTextField.bottomAnchor, constant: 20),
            numberOfTriesLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            numberOfTriesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4, constant: 0),
            
            viewOfCharButtons.topAnchor.constraint(equalTo: numberOfTriesLabel.bottomAnchor, constant: 40),
            viewOfCharButtons.widthAnchor.constraint(equalToConstant: 720),
            viewOfCharButtons.heightAnchor.constraint(equalToConstant: 350),
            viewOfCharButtons.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            viewOfCharButtons.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10)
        ])
    }
    
    @objc private func handleCharButtonTapped(_ button: UIButton) {
        // deduct number of tries
        totalTried += 1
        
        guard
            let buttonTitle = button.currentTitle,
            solutionInChars.contains(buttonTitle)
        else {
            if totalTried == maximumTries {
                let ac = UIAlertController(title: "Out Of Tries", message: "Sorry, \(maximumTries) tries is reached. \n Game will be restarted!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: { _ in
                    // restart the game ?
                }))
                present(ac, animated: true, completion: nil)
            }

            return
        }
        
        tappedCorrectChars.append(buttonTitle)
        currentAnswerButtons.append(button)
        button.isHidden = true
        
        showCurrentAnswerText()
    }
    
    private func showCurrentAnswerText() {
        var currentText = ""
        for eachChar in solutionInChars {
            if tappedCorrectChars.contains(eachChar) {
                currentText.append(" \(eachChar) ")
            } else {
                currentText.append(" _ ")
            }
        }
        
        currentAnswerTextField.text = currentText
    }
    
    @objc private func fetchData() {
        guard
            let fileUrl = Bundle.main.url(forResource: "words", withExtension: "txt"),
            let fileData = try? String(contentsOf: fileUrl)
        else { return }
        
        arrData = fileData.components(separatedBy: "\n")
        
        restartGame()
    }
    
    private func restartGame() {
        guard !arrData.isEmpty else { return }
        
        arrData.shuffle()
        
        let dataLine = arrData[0]
        
        let arrDataOfEachLine = dataLine.components(separatedBy: ":")
        
        guard arrDataOfEachLine.count == 2 else { return }
        
        let solution = arrDataOfEachLine[0]
        clue = arrData[1]
        
        for (_, eachCharacter) in solution.enumerated() {
            solutionInChars.append(String(eachCharacter).capitalized)
        }
        print(solutionInChars)
        performSelector(onMainThread: #selector(fulfillViewWithData), with: nil, waitUntilDone: false)
    }
    
    @objc private func fulfillViewWithData() {
        showCurrentAnswerText()
    }
}

