//
//  ViewController.swift
//  HangmanGame
//
//  Created by Pham Anh Tuan on 8/6/22.
//

import UIKit

class ViewController: UIViewController {

    private var nextWordButton: UIButton!
    private var scoreLabel: UILabel!
    private var clueLabel: UILabel!
    private var currentAnswerTextField: UITextField!
    private var currentAnswerButtons = [UIButton]()
    private var numberOfTriesLabel: UILabel!
    private let viewOfCharButtons = UIView()
    
    private var solutionInChars: [String] = []
    private var tappedCorrectChars: [String] = []
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var clue: String = ""  {
        didSet {
            clueLabel.text = "\(clue)"
        }
    }
    private var totalTried: Int = 0 {
        didSet {
            numberOfTriesLabel.text = "Number of tries: \(totalTried)/\(maximumTries)"
        }
    }
    private var arrData = [String]()
    
    private let maximumTries = 7
    
    private var layoutConstraints = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        performSelector(inBackground: #selector(fetchData), with: nil)
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        buildNextWordLabel()
        buildScoreLabel()
        buildClueLabel()
        buildCurrentAnswerTextField()
        buildTriesLabel()
        buildViewWithCharacterButtonsInside()
        
        setupLayoutConstraints()
    }
    
    // MARK: - Button Tapped
    @objc private func handleLoadAnotherWordTapped() {
        let alertMessage =
        """
        Score will be deducted by one.
        Are you ok?
        """
        
        let ac = UIAlertController(title: "Guess Another Word?", message: alertMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.deductScore(by: 1)
            self?.restartGame()
        }))
        
        present(ac, animated: true, completion: nil)

    }
    
    @objc private func handleCharButtonTapped(_ button: UIButton) {
        currentAnswerButtons.append(button)
        button.isHidden = true
        
        guard
            let buttonTitle = button.currentTitle,
            solutionInChars.contains(buttonTitle)
        else {
            // deduct number of tries
            totalTried += 1
            
            if totalTried == maximumTries {
                deductScore(by: 1)
                
                let alertMessage =
                """
                Sorry, \(maximumTries) tries is reached.
                Score: \(score)
                Game will be restarted!
                """
                let ac = UIAlertController(title: "Out Of Tries", message: alertMessage, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: { [weak self] _ in
                    self?.restartGame()
                }))
                present(ac, animated: true, completion: nil)
            }

            return
        }
        
        tappedCorrectChars.append(buttonTitle)
        showCurrentAnswerText()
        showAlertIfWordIsSolved()
    }
    
    // MARK: - Build UI View
    private func buildViewWithCharacterButtonsInside() {
        viewOfCharButtons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewOfCharButtons)

        var buttonConfigTint = UIButton.Configuration.tinted()
        buttonConfigTint.buttonSize = .large
        
        let charButtonWidth = 100
        let charButtonHeight = 44
        let buttonSpacing = 20
        
        let letters = (97...122).map({Character(UnicodeScalar($0))})
        
        var curCharIndex = 0
        outerLoop: for curRow in 0..<4 {
        for curCol in 0..<7 {
                guard curCharIndex < letters.count else {
                    break outerLoop
                }
                
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
        
        layoutConstraints += [
            viewOfCharButtons.topAnchor.constraint(equalTo: numberOfTriesLabel.bottomAnchor, constant: 40),
            viewOfCharButtons.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.65, constant: 0),
            viewOfCharButtons.heightAnchor.constraint(equalToConstant: 350),
            viewOfCharButtons.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            viewOfCharButtons.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -10)
        ]
    }
    
    private func buildTriesLabel() {
        numberOfTriesLabel = UILabel()
        numberOfTriesLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfTriesLabel.textAlignment = .center
        numberOfTriesLabel.text = "Number of tries: \(totalTried)/\(maximumTries)"
        view.addSubview(numberOfTriesLabel)
        
        layoutConstraints += [
            numberOfTriesLabel.topAnchor.constraint(equalTo: currentAnswerTextField.bottomAnchor, constant: 20),
            numberOfTriesLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            numberOfTriesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4, constant: 0),
        ]
    }
    
    private func buildCurrentAnswerTextField() {
        currentAnswerTextField = UITextField()
        currentAnswerTextField.translatesAutoresizingMaskIntoConstraints = false
        currentAnswerTextField.textAlignment = .center
        currentAnswerTextField.text = ""
        currentAnswerTextField.font = UIFont.systemFont(ofSize: 40)
        view.addSubview(currentAnswerTextField)
        
        layoutConstraints += [
            currentAnswerTextField.topAnchor.constraint(equalTo: clueLabel.bottomAnchor, constant: 20),
            currentAnswerTextField.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            currentAnswerTextField.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: 0)
        ]
    }
    
    private func buildClueLabel() {
        clueLabel = UILabel()
        clueLabel.translatesAutoresizingMaskIntoConstraints = false
        clueLabel.textAlignment = .center
        clueLabel.text = "CLUE"
        clueLabel.font = UIFont.systemFont(ofSize: 30)
        clueLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(clueLabel)
        
        layoutConstraints += [
            clueLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            clueLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            clueLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: 0),
        ]
    }
    
    private func buildNextWordLabel() {
        nextWordButton = UIButton()
        nextWordButton.translatesAutoresizingMaskIntoConstraints = false
        nextWordButton.setTitle("Give up! Load Another Word!", for: .normal)
        nextWordButton.contentHorizontalAlignment = .left
        
        nextWordButton.addTarget(self, action: #selector(handleLoadAnotherWordTapped), for: .touchUpInside)
        nextWordButton.setTitleColor(.blue, for: .normal)
        view.addSubview(nextWordButton)
        
        layoutConstraints += [
            nextWordButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            nextWordButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            nextWordButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.5, constant: 0)
        ]
    }
    
    private func buildScoreLabel() {
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .right
        view.addSubview(scoreLabel)
        
        layoutConstraints += [
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: nextWordButton.centerYAnchor),
            nextWordButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.5, constant: 0)
        ]
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    // MARK: - Extra Functions
    private func showCurrentAnswerText() {
        var tmptappedCorrectCharsInSameOrderOfSolution = [String]()
        var currentText = ""
        for eachChar in solutionInChars {
            if tappedCorrectChars.contains(eachChar) {
                currentText.append(" \(eachChar) ")
                tmptappedCorrectCharsInSameOrderOfSolution.append(eachChar)
            } else {
                currentText.append(" _ ")
            }
        }
        
        tappedCorrectChars = tmptappedCorrectCharsInSameOrderOfSolution
        
        DispatchQueue.main.async {
            self.currentAnswerTextField.text = currentText
        }
    }
    
    private func showAlertIfWordIsSolved() {
        guard
            solutionInChars.elementsEqual(tappedCorrectChars)
        else { return }
        
        score += 1
        
        let solutionInWord = solutionInChars.joined(separator: "")
        let alertMessage = """
        You solved word: \(solutionInWord)!
        Score: \(score)
        Do you want to guess another word?
        """
        
        let ac = UIAlertController(title: "Congrats!", message: alertMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.restartGame()
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func fetchData() {
        guard
            let fileUrl = Bundle.main.url(forResource: "words", withExtension: "txt"),
            let fileData = try? String(contentsOf: fileUrl)
        else { return }
        
        arrData = fileData.components(separatedBy: "\n")
        
        performSelector(onMainThread: #selector(restartGame), with: nil, waitUntilDone: false)
    }
    
    @objc private func restartGame() {
        guard !arrData.isEmpty else { return }
        
        resetData()
        selectWordToPlayRandomly()
    }
    
    private func resetData() {
        for eachButton in currentAnswerButtons {
            eachButton.isHidden = false
        }
        
        clue = ""
        totalTried = 0
        
        currentAnswerButtons.removeAll(keepingCapacity: true)
        tappedCorrectChars.removeAll(keepingCapacity: true)
        solutionInChars.removeAll(keepingCapacity: true)
    }
    
    private func selectWordToPlayRandomly() {
        arrData.shuffle()
        
        let dataLine = arrData[0]
        
        let arrDataOfEachLine = dataLine.components(separatedBy: ":")
        
        guard isValidDataLine(arrData: arrDataOfEachLine) else {
            arrData.removeFirst()
            
            if arrData.count > 0 {
                selectWordToPlayRandomly()
            }
            
            return
        }
        
        let solution = arrDataOfEachLine[0]
        clue = arrDataOfEachLine[1]
        
        for (_, eachCharacter) in solution.enumerated() {
            solutionInChars.append(String(eachCharacter).capitalized)
        }
        
        showCurrentAnswerText()
        print(solutionInChars)
    }
    
    private func isValidDataLine(arrData: [String]) -> Bool {
        return arrData.count == 2
    }
    
    private func deductScore(by value: Int) {
        score = score >= value ? score - value : score
    }
}

