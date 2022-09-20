//
//  PlayViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/17/22.
//

import UIKit

class PlayViewController: UIViewController {

    var buttonCards = [UIButton]()
    var layoutConstraints = [NSLayoutConstraint]()
    var cancelButton: UIButton!
    
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
        print(">>> \(button.tag)")
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
        let buttonCardsView = UIView()
        buttonCardsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonCardsView)
        
        let buttonCardWidth = 150
        let buttonCardHeight = 150
        let buttonCardSpacing = 5
        
        var tinted = UIButton.Configuration.tinted()
        tinted.buttonSize = .large
        
        for curRow in 0..<4 {
            for curCol in 0..<4 {
                let cardButton = UIButton(configuration: tinted, primaryAction: nil)
                
                var xPosition = curCol * buttonCardWidth
                if curCol > 0 {
                    xPosition += curCol * buttonCardSpacing
                }
                
                cardButton.frame = CGRect(x: xPosition, y: curRow * (buttonCardHeight + buttonCardSpacing) , width: buttonCardWidth, height: buttonCardHeight)
                
                cardButton.titleLabel?.textAlignment = .center
                cardButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
                cardButton.setTitle("AC", for: .normal)
                cardButton.tag = curRow
                
                cardButton.addTarget(self, action: #selector(handleCardButtonTapped(_:)), for: .touchUpInside)
                
                buttonCards.append(cardButton)
                buttonCardsView.addSubview(cardButton)
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
    
}
