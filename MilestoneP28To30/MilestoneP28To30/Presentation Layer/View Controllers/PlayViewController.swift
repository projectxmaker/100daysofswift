//
//  PlayViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/17/22.
//

import UIKit

class PlayViewController: UIViewController {
    var cardGameEngine = CardGameEngine()
    
    var cardButtons = [UIButton]()
    var layoutConstraints = [NSLayoutConstraint]()
    var cancelButton: UIButton!
    var buttonCardsView: UIView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        setupRoundLabel()
        setupCancelButton()
        setupCardButtons()

        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationItems()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Navigation Controller
    func setupNavigationItems() {
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Button Handlers
    @objc func handleCancelButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleCardButtonTapped(_ button: UIButton) {
        if cardGameEngine.handleCardTapped(cardIndex: button.tag) {
            faceUpCardButtonByIndexes([button.tag])
        }

        cardGameEngine.evaluateFacedUpCards { [weak self] cardIndexes in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.resolveCardButtonsByIndexes(cardIndexes)
            }
        } executeIfFaceDown: { [weak self] cardIndexes in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.faceDownCardButtonsByIndexes(cardIndexes)
            }
        }

    }
    
    // MARK: - Layout
    func setupRoundLabel() {
        let roundLabel = UILabel()
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.text = "Round 1"
        roundLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        roundLabel.textAlignment = .center
        roundLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(roundLabel)
        
        // set up layout constraints
        layoutConstraints += [
            roundLabel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            roundLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            roundLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }
    
    func setupCardButtons() {
        buttonCardsView = UIView()
        buttonCardsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonCardsView)
        
        let buttonCardWidth = 150
        let buttonCardHeight = 150
        let buttonCardSpacing = 5
        
        var tinted = UIButton.Configuration.tinted()
        tinted.buttonSize = .large
        
        var shuffedCards = cardGameEngine.getCards()
        var shuffedCardCounter = 0
        
        for curRow in 0..<4 {
            for curCol in 0..<4 {
                let cardButton = UIButton(configuration: tinted, primaryAction: nil)
                
                var xPosition = curCol * buttonCardWidth
                if curCol > 0 {
                    xPosition += curCol * buttonCardSpacing
                }
                
                cardButton.frame = CGRect(x: xPosition, y: curRow * (buttonCardHeight + buttonCardSpacing) , width: buttonCardWidth, height: buttonCardHeight)
                
                shuffedCards.removeFirst()
                cardButton.tag = shuffedCardCounter
                
                shuffedCardCounter += 1
                
                cardButton.addTarget(self, action: #selector(handleCardButtonTapped(_:)), for: .touchUpInside)
                
                cardButtons.append(cardButton)
                buttonCardsView.addSubview(cardButton)
                faceDownCardButtonsByIndexes([cardButton.tag])
            }
        }
        
        // set up layout constraints
        layoutConstraints += [
            buttonCardsView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -20),
            buttonCardsView.centerXAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.centerXAnchor),
            buttonCardsView.widthAnchor.constraint(equalToConstant: 620),
            buttonCardsView.heightAnchor.constraint(equalToConstant: 620)
        ]
    }
    
    func setupCancelButton() {
        let cancelButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ]
        let cancelButtonTitleAttributedTitle = NSAttributedString(string: "Cancel", attributes: cancelButtonTitleAttributedKeys)
        
        cancelButton = UIButton(type: .roundedRect)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setAttributedTitle(cancelButtonTitleAttributedTitle, for: .normal)
        view.addSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(handleCancelButtonTapped), for: .touchUpInside)
        
        // set up layout constraints
        layoutConstraints += [
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cancelButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
            cancelButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }
    
    func removeCardButtonFromView(_ button: UIButton) {
        button.configuration?.baseBackgroundColor = UIColor.white
        button.configuration?.baseForegroundColor = UIColor.white
    }
    
    func faceUpCardButtonByIndexes(_ indexes: [Int]) {
        for eachIndex in indexes {
            let card = cardGameEngine.getCards()[eachIndex]
            let button = cardButtons[eachIndex]
            button.configuration?.baseForegroundColor = UIColor.yellow
            button.backgroundColor = UIColor.red

            let attributedTextKeys: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            ]
            
            let attributedText = NSAttributedString(string: card.name, attributes: attributedTextKeys)
            button.setAttributedTitle(attributedText, for: .normal)
            
            UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
    
    func faceDownCardButtonsByIndexes(_ indexes: [Int]) {
        for eachIndex in indexes {
            let button = cardButtons[eachIndex]
            button.configuration?.baseForegroundColor = UIColor.white
            button.backgroundColor = UIColor.gray
            
            let attributedTextKeys: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
            ]
            let attributedText = NSAttributedString(string: "?", attributes: attributedTextKeys)
            button.setAttributedTitle(attributedText, for: .normal)

            UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
        }
    }
    
    func resolveCardButtonsByIndexes(_ indexes: [Int]) {
        for eachIndex in indexes {
            let button = cardButtons[eachIndex]
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
                button.transform = CGAffineTransform(scaleX: 0, y: 0)
            })
        }
        
        if cardGameEngine.isAllCardsResolved() {
            endRound()
        }
    }
    
    func endRound() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playResultViewController = storyboard.instantiateViewController(withIdentifier: "PlayResultView")
        
        navigationController?.pushViewController(playResultViewController, animated: true)
    }
}
