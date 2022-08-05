//
//  ViewController.swift
//  Project8
//
//  Created by Pham Anh Tuan on 8/5/22.
//

import UIKit

class ViewController: UIViewController {

    private var scoreLabel: UILabel!
    private var clueLabel: UILabel!
    private var answerLabel: UILabel!
    private var currentAnswerTextField: UITextField!
    private var answerButtons = [UIButton]()
    
    private var level = 1
    private var score: Int! {
        didSet {
            scoreLabel.text = "Score: \(score ?? 0)"
        }
    }
    private var solutions = [String]()
    private var activatedAnswerButtons = [UIButton]()
    
    private var submitButton: UIButton!
    private var clearButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resetData()
        loadLevel()
        setupTargetActionForButtons()
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
        clueLabel.text = "Clue Label"
        clueLabel.numberOfLines = 0
        clueLabel.textAlignment = .left
        clueLabel.font = UIFont.systemFont(ofSize: 24)
        clueLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(clueLabel)
        
        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.text = "Answer label"
        answerLabel.numberOfLines = 0
        answerLabel.textAlignment = .right
        answerLabel.font = UIFont.systemFont(ofSize: 24)
        answerLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answerLabel)
        
        currentAnswerTextField = UITextField()
        currentAnswerTextField.translatesAutoresizingMaskIntoConstraints = false
        currentAnswerTextField.placeholder = "Tap letters to guess"
        currentAnswerTextField.font = UIFont.systemFont(ofSize: 44)
        currentAnswerTextField.textAlignment = .center
        currentAnswerTextField.isUserInteractionEnabled = false
        view.addSubview(currentAnswerTextField)
        
        var filled = UIButton.Configuration.filled()
        filled.buttonSize = .large
        
        submitButton = UIButton(configuration: filled, primaryAction: nil)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("SUBMIT", for: .normal)
        view.addSubview(submitButton)
        
        clearButton = UIButton(configuration: filled, primaryAction: nil)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("CLEAR", for: .normal)
        view.addSubview(clearButton)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        let buttonWidth = 150
        let buttonHeight = 44
        let spacingBetweenButtons = 5
        
        var tinted = UIButton.Configuration.tinted()
        tinted.buttonSize = .large
        
        for curRow in 0..<4 {
            for curCol in 0..<5 {
                let button = UIButton(configuration: tinted, primaryAction: nil)
                
                var xPosition = curCol * buttonWidth
                if curCol > 0 {
                    xPosition += curCol * spacingBetweenButtons
                }
                
                button.frame = CGRect(x: xPosition, y: curRow * buttonHeight * 2, width: buttonWidth, height: buttonHeight)
                
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
                button.setTitle("AC", for: .normal)
                
                answerButtons.append(button)
                buttonsView.addSubview(button)
            }
        }
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            
            clueLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            clueLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            clueLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6, constant: -100),
            
            answerLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answerLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answerLabel.centerYAnchor.constraint(equalTo: clueLabel.centerYAnchor),
            answerLabel.heightAnchor.constraint(equalTo: clueLabel.heightAnchor),
            
            currentAnswerTextField.topAnchor.constraint(equalTo: clueLabel.bottomAnchor, constant: 20),
            currentAnswerTextField.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            currentAnswerTextField.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6),
            
            submitButton.topAnchor.constraint(equalTo: currentAnswerTextField.bottomAnchor, constant: 40),
            submitButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: -100),
            
            clearButton.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
            clearButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 100),
            
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 40),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10),
            buttonsView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320)
        ])
    }
    
    // MARK: - Extra Functions
    private func resetData() {
        score = 0
        solutions.removeAll(keepingCapacity: true)
        
        clearCurrentAnswer()
    }
    
    private func loadLevel() {
        if let levelFileUrl = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelFileContent = try? String(contentsOf: levelFileUrl) {
                var clueString = ""
                var answerString = ""
                var answerBits = [String]()
                
                let lines = levelFileContent.components(separatedBy: "\n")
                
                for (index, line) in lines.enumerated() {
                    let lineData = line.components(separatedBy: ":")
                    let answer = lineData[0]
                    let tempAnswerString = answer.replacingOccurrences(of: "|", with: "")
                    
                    let clue = lineData[1]
                    
                    clueString += "\(index + 1). \(clue) \n"
                    answerString += "\(tempAnswerString.count) letters \n"
                    
                    answerBits += answer.components(separatedBy: "|")
                    solutions.append(tempAnswerString)
                }
                
                // fill data into the views
                clueString = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
                clueLabel.text = clueString
                
                answerString = answerString.trimmingCharacters(in: .whitespacesAndNewlines)
                answerLabel.text = answerString
                
                if answerBits.count == answerButtons.count {
                    answerBits.shuffle()
                    for (index, eachAnswerBit) in answerBits.enumerated() {
                        answerButtons[index].setTitle(eachAnswerBit, for: .normal)
                    }
                }
            }
        }
    }
    
    private func setupTargetActionForButtons() {
        submitButton.addTarget(self, action: #selector(handleSubmitButtonTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(handleClearButtonTapped), for: .touchUpInside)
        
        for eachAnswerButton in answerButtons {
            eachAnswerButton.addTarget(self, action: #selector(handleAnswerButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func clearCurrentAnswer() {
        currentAnswerTextField.text = ""
        
        for eachActivatedButton in activatedAnswerButtons {
            eachActivatedButton.isHidden = false
        }
        
        activatedAnswerButtons.removeAll(keepingCapacity: true)
    }
    
    private func hasNextLevel() -> Bool {
        let nextLevel = level + 1
        guard let _ = Bundle.main.url(forResource: "level\(nextLevel)", withExtension: "txt") else {
            return false
        }
        
        return true
    }
    
    // MARK: - Functions For Button Tapped
    
    @objc private func handleSubmitButtonTapped() {
        guard
            let answeredText = currentAnswerTextField.text,
            let answerIndex = solutions.firstIndex(of: answeredText),
            var arrAnswersInAnswerLabel = answerLabel.text?.components(separatedBy: "\n")
        else { return }
        
        arrAnswersInAnswerLabel[answerIndex] = answeredText
        answerLabel.text = arrAnswersInAnswerLabel.joined(separator: "\n")
        
        score += 1
        
        handleClearButtonTapped()
        
        if score == solutions.count {
            let ac = UIAlertController(title: "Congrats!", message: "Completed Level \(level)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if hasNextLevel() {
                ac.addAction(UIAlertAction(title: "Next Level", style: .default, handler: { [weak self] _ in
                    self?.level += 1
                    self?.resetData()
                    self?.loadLevel()
                }))
            }
            
            present(ac, animated: true, completion: nil)
        }
    }
    
    @objc private func handleClearButtonTapped() {
        clearCurrentAnswer()
    }
    
    @objc private func handleAnswerButtonTapped(_ button: UIButton) {
        guard let buttonTitle = button.currentTitle else { return }
        
        currentAnswerTextField.text = currentAnswerTextField.text?.appending(buttonTitle)
        
        activatedAnswerButtons.append(button)
        button.isHidden = true
    }
}

