//
//  PlayResultViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/18/22.
//

import UIKit

class PlayResultViewController: UIViewController {

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        let roundLabel = UILabel()
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.text = "Round 1\nCompleted"
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

        var tinted = UIButton.Configuration.tinted()
        tinted.buttonSize = .large
        tinted.title = "PLAY NEXT"
        tinted.titleAlignment = .center
        
        let playNextButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 50),
        ]
        let playNextButtonTitleAttributedString = NSAttributedString(string: "PLAY NEXT", attributes: playNextButtonTitleAttributedKeys)

        let playNextButton = UIButton(configuration: tinted)
        playNextButton.translatesAutoresizingMaskIntoConstraints = false
        playNextButton.setAttributedTitle(playNextButtonTitleAttributedString, for: .normal)
        view.addSubview(playNextButton)

        let cancelButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .font: UIFont.preferredFont(forTextStyle: .callout),
        ]
        let cancelButtonTitleAttributedTitle = NSAttributedString(string: "Cancel", attributes: cancelButtonTitleAttributedKeys)

        let cancelButton = UIButton(type: .roundedRect)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setAttributedTitle(cancelButtonTitleAttributedTitle, for: .normal)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            roundLabel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            roundLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            roundLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            roundCongratsLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 20),
            roundCongratsLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            roundCongratsLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            playNextButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            playNextButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playNextButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cancelButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
            cancelButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
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

}
