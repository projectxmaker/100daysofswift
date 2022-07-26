//
//  ViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/17/22.
//

import UIKit

class MainViewController: UIViewController {
    var cardGameEngine = AppEngine()
    var playButton: UIButton!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        let appTitleLabel = UILabel()
        appTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        appTitleLabel.text = "CARD PAIR GAME"
        appTitleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        appTitleLabel.textAlignment = .center
        view.addSubview(appTitleLabel)

        var tinted = UIButton.Configuration.tinted()
        tinted.buttonSize = .large
        tinted.titleAlignment = .center
        
        let playButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 50),
        ]
        let playButtonTitleAttributedString = NSAttributedString(string: "PLAY", attributes: playButtonTitleAttributedKeys)

        playButton = UIButton(configuration: tinted)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setAttributedTitle(playButtonTitleAttributedString, for: .normal)
        view.addSubview(playButton)

        playButton.addTarget(self, action: #selector(handlePlayButtonTapped), for: .touchUpInside)
        
        let cardManagementButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .font: UIFont.preferredFont(forTextStyle: .callout),
        ]
        let cardManagementButtonTitleAttributedTitle = NSAttributedString(string: "Card Management", attributes: cardManagementButtonTitleAttributedKeys)

        let cardManagementButton = UIButton(type: .roundedRect)
        cardManagementButton.translatesAutoresizingMaskIntoConstraints = false
        cardManagementButton.setAttributedTitle(cardManagementButtonTitleAttributedTitle, for: .normal)
        view.addSubview(cardManagementButton)
        
        cardManagementButton.addTarget(self, action: #selector(handleCardManagementButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            appTitleLabel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            appTitleLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            appTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            playButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            cardManagementButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cardManagementButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
            cardManagementButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Button Handlers
    @objc func handleCardManagementButtonTapped() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let cardListTableViewController = mainStoryboard.instantiateViewController(withIdentifier: "CardListView")
        
        navigationController?.pushViewController(cardListTableViewController, animated: true)
    }
    
    @objc func handlePlayButtonTapped() {
        playButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.1, options: [.curveEaseInOut]) {
            self.playButton.transform = .identity
        } completion: { _ in
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let playViewTableViewController = mainStoryboard.instantiateViewController(withIdentifier: "PlayView")
            
            self.navigationController?.pushViewController(playViewTableViewController, animated: true)
        }


    }
}

