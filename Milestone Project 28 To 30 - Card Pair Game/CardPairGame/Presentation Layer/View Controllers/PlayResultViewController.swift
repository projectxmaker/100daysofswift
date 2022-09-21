//
//  PlayResultViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/18/22.
//

import UIKit

class PlayResultViewController: UIViewController {

    var layoutConstraints = [NSLayoutConstraint]()
    var round: Int = 1
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        setupRoundLabels()
        setupPlayNextButton()
        setupCancelButton()

        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Layout
    func setupRoundLabels() {
        let roundLabel = UILabel()
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.text = "Round \(round)\nCompleted"
        roundLabel.numberOfLines = 2
        roundLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        roundLabel.textAlignment = .center
        view.addSubview(roundLabel)

        let roundCongratsLabel = UILabel()
        roundCongratsLabel.translatesAutoresizingMaskIntoConstraints = false
        roundCongratsLabel.text = "Congrats!\nYou're really excellent!"
        roundCongratsLabel.numberOfLines = 2
        roundCongratsLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        roundCongratsLabel.textAlignment = .center
        view.addSubview(roundCongratsLabel)
        
        // set up layout constraints
        layoutConstraints += [
            roundLabel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            roundLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            roundLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            roundCongratsLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 20),
            roundCongratsLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            roundCongratsLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }
    
    func setupPlayNextButton() {
        var tinted = UIButton.Configuration.tinted()
        tinted.buttonSize = .large
        tinted.titleAlignment = .center
        
        let playNextButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 50),
        ]
        let playNextButtonTitleAttributedString = NSAttributedString(string: "PLAY NEXT", attributes: playNextButtonTitleAttributedKeys)

        let playNextButton = UIButton(configuration: tinted)
        playNextButton.translatesAutoresizingMaskIntoConstraints = false
        playNextButton.setAttributedTitle(playNextButtonTitleAttributedString, for: .normal)
        view.addSubview(playNextButton)
        
        playNextButton.addTarget(self, action: #selector(handlePlayNextButtonTapped), for: .touchUpInside)
        
        // set up layout constraints
        layoutConstraints += [
            playNextButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            playNextButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playNextButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ]
    }
    
    func setupCancelButton() {
        let cancelButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ]
        let cancelButtonTitleAttributedTitle = NSAttributedString(string: "Cancel", attributes: cancelButtonTitleAttributedKeys)
        
        let cancelButton = UIButton(type: .roundedRect)
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
    
    // MARK: - Button Handlers
    @objc func handleCancelButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handlePlayNextButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let playViewController = storyboard.instantiateViewController(withIdentifier: "PlayView") as? PlayViewController else { return }
        
        playViewController.round = round + 1
        
        navigationController?.pushViewController(playViewController, animated: true)
    }
}
