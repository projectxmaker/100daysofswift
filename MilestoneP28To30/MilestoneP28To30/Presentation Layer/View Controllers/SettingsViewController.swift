//
//  SettingsViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/18/22.
//

import UIKit

class SettingsViewController: UIViewController {

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        let settingsTitleLabel = UILabel()
        settingsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsTitleLabel.text = "Settings"
        settingsTitleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        settingsTitleLabel.textAlignment = .center
        view.addSubview(settingsTitleLabel)

        var tinted = UIButton.Configuration.tinted()
        tinted.buttonSize = .large
        tinted.titleAlignment = .center
        
        let biometricButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
        ]
        let biometricButtonTitleAttributedString = NSAttributedString(string: "Face ID/Touch ID: ON", attributes: biometricButtonTitleAttributedKeys)

        let biometricButton = UIButton(configuration: tinted)
        biometricButton.translatesAutoresizingMaskIntoConstraints = false
        biometricButton.setAttributedTitle(biometricButtonTitleAttributedString, for: .normal)
        view.addSubview(biometricButton)

        let passcodeButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
        ]
        let passcodeButtonTitleAttributedString = NSAttributedString(string: "Passcode: ON", attributes: passcodeButtonTitleAttributedKeys)

        let passcodeButton = UIButton(configuration: tinted)
        passcodeButton.translatesAutoresizingMaskIntoConstraints = false
        passcodeButton.setAttributedTitle(passcodeButtonTitleAttributedString, for: .normal)
        view.addSubview(passcodeButton)
        
        let setPasscodeButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
        ]
        let setPasscodeButtonTitleAttributedString = NSAttributedString(string: "Set Passcode", attributes: setPasscodeButtonTitleAttributedKeys)

        let setPasscodeButton = UIButton(configuration: tinted)
        setPasscodeButton.translatesAutoresizingMaskIntoConstraints = false
        setPasscodeButton.setAttributedTitle(setPasscodeButtonTitleAttributedString, for: .normal)
        view.addSubview(setPasscodeButton)
        

        NSLayoutConstraint.activate([
            settingsTitleLabel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            settingsTitleLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            settingsTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            biometricButton.topAnchor.constraint(equalTo: settingsTitleLabel.bottomAnchor, constant: 100),
            biometricButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            biometricButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            passcodeButton.topAnchor.constraint(equalTo: biometricButton.bottomAnchor, constant: 50),
            passcodeButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            passcodeButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            setPasscodeButton.topAnchor.constraint(equalTo: passcodeButton.bottomAnchor, constant: 20),
            setPasscodeButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            setPasscodeButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
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
