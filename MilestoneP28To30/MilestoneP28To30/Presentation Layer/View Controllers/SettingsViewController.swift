//
//  SettingsViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/18/22.
//

import UIKit
import LocalAuthentication

class SettingsViewController: UIViewController {
    var settingsTitleLabel: UILabel!
    var biometricButton: UIButton!
    var passcodeButton: UIButton!
    var setPasscodeButton: UIButton!
    var resetCardsButton: UIButton!
    
    var layoutConstraints = [NSLayoutConstraint]()
    
    var tinted = UIButton.Configuration.tinted()
    
    var enabledBiometric: Bool = false {
        didSet {
            saveBiometricSetting()
            setLabelOfBiometricButton()
        }
    }
    
    let biometricSettingKey = "com.projectxmaker.cardgame.settings.biometric"
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        tinted.buttonSize = .large
        tinted.titleAlignment = .center
        
        setupTitleLabel()
        setupBiometricButton()
        setupPasscode()
        setupResetCardButton()

        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadSettings()
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
    func setupTitleLabel() {
        settingsTitleLabel = UILabel()
        settingsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsTitleLabel.text = "Settings"
        settingsTitleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        settingsTitleLabel.textAlignment = .center
        view.addSubview(settingsTitleLabel)
        
        layoutConstraints += [
            settingsTitleLabel.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            settingsTitleLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            settingsTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }
    
    func setupBiometricButton() {
        biometricButton = UIButton(configuration: tinted)
        biometricButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(biometricButton)
        
        setLabelOfBiometricButton()
        
        biometricButton.addTarget(self, action: #selector(handleBiometricButtonTapped), for: .touchUpInside)
        
        layoutConstraints += [
            biometricButton.topAnchor.constraint(equalTo: settingsTitleLabel.bottomAnchor, constant: 100),
            biometricButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            biometricButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }
    
    func setupPasscode() {
        let passcodeButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
        ]
        let passcodeButtonTitleAttributedString = NSAttributedString(string: "Passcode: ON", attributes: passcodeButtonTitleAttributedKeys)

        passcodeButton = UIButton(configuration: tinted)
        passcodeButton.translatesAutoresizingMaskIntoConstraints = false
        passcodeButton.setAttributedTitle(passcodeButtonTitleAttributedString, for: .normal)
        view.addSubview(passcodeButton)
        
        let setPasscodeButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
        ]
        let setPasscodeButtonTitleAttributedString = NSAttributedString(string: "Set Passcode", attributes: setPasscodeButtonTitleAttributedKeys)

        setPasscodeButton = UIButton(configuration: tinted)
        setPasscodeButton.translatesAutoresizingMaskIntoConstraints = false
        setPasscodeButton.setAttributedTitle(setPasscodeButtonTitleAttributedString, for: .normal)
        view.addSubview(setPasscodeButton)
        
        layoutConstraints += [
            passcodeButton.topAnchor.constraint(equalTo: biometricButton.bottomAnchor, constant: 50),
            passcodeButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            passcodeButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            setPasscodeButton.topAnchor.constraint(equalTo: passcodeButton.bottomAnchor, constant: 20),
            setPasscodeButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            setPasscodeButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }
    
    func setupResetCardButton() {
        let resetCardsButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.red
        ]
        let resetCardsButtonTitleAttributedString = NSAttributedString(string: "Reset Cards", attributes: resetCardsButtonTitleAttributedKeys)

        let resetCardsButton = UIButton(configuration: tinted)
        resetCardsButton.translatesAutoresizingMaskIntoConstraints = false
        resetCardsButton.setAttributedTitle(resetCardsButtonTitleAttributedString, for: .normal)
        view.addSubview(resetCardsButton)
        
        resetCardsButton.addTarget(self, action: #selector(handleResetCardsButtonTapped), for: .touchUpInside)
        
        layoutConstraints += [
            resetCardsButton.topAnchor.constraint(equalTo: setPasscodeButton.bottomAnchor, constant: 50),
            resetCardsButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            resetCardsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }

    // MARK: - Handled Methods Of Buttons
    @objc func handleBiometricButtonTapped() {
        authenticateWithBiometric()
    }
    
    @objc func handleResetCardsButtonTapped() {
        let info = "Card Pair list will be reset to default.\nAll changes you made will be lost.\n Do you want to do that?"
        let ac = UIAlertController(title: "Reset Cards", message: info, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.resetCards()
        }))
        
        if #available(iOS 16.0, *) {
            ac.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(ac, animated: true)
    }
    
    @objc func resetCards() {
        CardPairManager.shared.resetCards()
    }
    
    func authenticateWithBiometric() {
        let context = LAContext()
        var error: NSError?

        if !enabledBiometric {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                enabledBiometric = true
                let reason = "It's used to unlock Card Management feature!"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async { [weak self] in
                        if success {
                            self?.enabledBiometric = true
                        } else {
                            let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)

                            ac.addAction(UIAlertAction(title: "Ok", style: .default))
                            
                            ac.popoverPresentationController?.barButtonItem = self?.navigationItem.rightBarButtonItem
                            self?.present(ac, animated: true)
                        }
                    }
                }
            } else {
                let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                
                ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
                present(ac, animated: true)
            }
        } else {
            enabledBiometric = false
        }
    }
    
    // MARK: - Extra Funcs
    func loadSettings() {
        enabledBiometric = UserDefaults.standard.bool(forKey: biometricSettingKey)
    }
    
    func saveBiometricSetting() {
        UserDefaults.standard.set(enabledBiometric, forKey: biometricSettingKey)
    }
    
    func setLabelOfBiometricButton() {
        guard let button = biometricButton else { return }
        
        let newTitle = "Face ID/Touch ID: \(enabledBiometric ? "ON" : "OFF")"
        let attributedString = getAttributedTitleForBiometricButton(newTitle: newTitle)

        button.setAttributedTitle(attributedString, for: .normal)
    }
    
    func getAttributedTitleForBiometricButton(newTitle: String) -> NSAttributedString {
        let biometricButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
        ]
        
        return NSAttributedString(string: newTitle, attributes: biometricButtonTitleAttributedKeys)
    }
}
