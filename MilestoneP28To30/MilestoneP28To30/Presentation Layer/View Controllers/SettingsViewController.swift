//
//  SettingsViewController.swift
//  MilestoneP28To30
//
//  Created by Pham Anh Tuan on 9/18/22.
//

import UIKit
import LocalAuthentication

class SettingsViewController: UIViewController {
    var appEngine = AppEngine()
    
    var settingsTitleLabel: UILabel!
    var biometricButton: UIButton!
    var passcodeStateButton: UIButton!
    var setPasscodeButton: UIButton!
    var resetCardsButton: UIButton!
    
    var layoutConstraints = [NSLayoutConstraint]()
    
    var tinted = UIButton.Configuration.tinted()
    
    var enabledBiometric: Bool {
        get {
            appEngine.settings.biometricState
        }
        
        set (newValue) {
            appEngine.settings.biometricState = newValue
            setLabelOfBiometricButton()
        }
    }
    
    var enabledPasscodeState: Bool {
        get {
            appEngine.settings.passcodeState
        }
        
        set (newValue) {
            appEngine.settings.passcodeState = newValue
            setLabelOfPasscodeStateButton()
            switchSetPasscodeButton()
        }
    }
    
    var passcode: String? {
        get {
            appEngine.settings.passcode
        }
        
        set (newValue) {
            appEngine.settings.passcode = newValue
        }
    }
    
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

        passcodeStateButton = UIButton(configuration: tinted)
        passcodeStateButton.translatesAutoresizingMaskIntoConstraints = false
        passcodeStateButton.setAttributedTitle(passcodeButtonTitleAttributedString, for: .normal)
        view.addSubview(passcodeStateButton)
        
        passcodeStateButton.addTarget(self, action: #selector(handlePasscodeStateButtonTapped), for: .touchUpInside)
        
        let setPasscodeButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
        ]
        let setPasscodeButtonTitleAttributedString = NSAttributedString(string: "Set Passcode", attributes: setPasscodeButtonTitleAttributedKeys)

        setPasscodeButton = UIButton(configuration: tinted)
        setPasscodeButton.translatesAutoresizingMaskIntoConstraints = false
        setPasscodeButton.setAttributedTitle(setPasscodeButtonTitleAttributedString, for: .normal)
        view.addSubview(setPasscodeButton)
        
        setPasscodeButton.addTarget(self, action: #selector(handleSetPasscodeButtonTapped), for: .touchUpInside)
        
        layoutConstraints += [
            passcodeStateButton.topAnchor.constraint(equalTo: biometricButton.bottomAnchor, constant: 50),
            passcodeStateButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            passcodeStateButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            setPasscodeButton.topAnchor.constraint(equalTo: passcodeStateButton.bottomAnchor, constant: 20),
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
    
    @objc func handlePasscodeStateButtonTapped() {
        if enabledPasscodeState {
            enabledPasscodeState = false
        } else {
            enabledPasscodeState = true
            
            showAlertToSetPasscodeIfNoPasscodeWasSetPreviously()
        }
    }
    
    @objc func handleSetPasscodeButtonTapped() {
        showAlertToSetPasscode()
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
        enabledBiometric = appEngine.settings.biometricState
        enabledPasscodeState = appEngine.settings.passcodeState
        passcode = appEngine.settings.passcode
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
    
    func setLabelOfPasscodeStateButton() {
        guard let button = passcodeStateButton else { return }
        
        let newTitle = "Passcode: \(enabledPasscodeState ? "ON" : "OFF")"
        let attributedString = getAttributedTitleForPasscodeButton(newTitle: newTitle)

        button.setAttributedTitle(attributedString, for: .normal)
    }
    
    func getAttributedTitleForPasscodeButton(newTitle: String) -> NSAttributedString {
        let biometricButtonTitleAttributedKeys: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
        ]
        
        return NSAttributedString(string: newTitle, attributes: biometricButtonTitleAttributedKeys)
    }
    
    func switchSetPasscodeButton() {
        if enabledPasscodeState {
            setPasscodeButton.isHidden = false
        } else {
            setPasscodeButton.isHidden = true
        }
    }
    
    func hasPasscode(execute: ((_ hasPasscode: Bool, _ passcode: String?) -> Void)? = nil) {
        var hasPasscode = false
        var existingPasscode: String?
        if let tmpPasscode = passcode {
            if !tmpPasscode.isEmpty {
                existingPasscode = tmpPasscode
                hasPasscode = true
            }
        }

        if let execute = execute {
            execute(hasPasscode, existingPasscode)
        }
    }
    
    func showAlertToSetPasscode() {
        showAlertToSetPasscodeWithConditions()
    }
    
    func showAlertToSetPasscode(withoutCancelButton: Bool) {
        showAlertToSetPasscodeWithConditions(withoutCancelButton: withoutCancelButton)
    }
    
    func showAlertToSetPasscode(errorMsg: String) {
        showAlertToSetPasscodeWithConditions(withoutCancelButton: false, errorMsg: errorMsg)
    }
    
    func showAlertToSetPasscodeWithConditions(withoutCancelButton: Bool? = false, errorMsg: String? = nil) {
        let withoutCancelButton = withoutCancelButton ?? false
        let info = errorMsg ?? "Set passcode to unlock Card Management feature"
        let ac = UIAlertController(title: "Passcode", message: info, preferredStyle: .alert)
        
        hasPasscode(execute: { [weak ac] hasPasscode, passcode in
            if hasPasscode {
                ac?.addTextField { textfield in
                    textfield.enablePasswordToggle()
                    textfield.placeholder = "Input existing passcode"
                }
            }
        })

        ac.addTextField { textfield in
            textfield.enablePasswordToggle()
            textfield.placeholder = "Input new passcode"
        }
        ac.addTextField { textfield in
            textfield.enablePasswordToggle()
            textfield.placeholder = "Confirm new passcode"
        }
        
        if !withoutCancelButton {
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak ac] _ in
            self?.hasPasscode { hasPasscode, passcode in
                let newPasscode: String
                let confirmNewPasscode: String
                var errorMsg = [String]()
                
                if hasPasscode {
                    let existingPasscode = ac?.textFields?[0].text
                    newPasscode = ac?.textFields?[1].text ?? ""
                    confirmNewPasscode = ac?.textFields?[2].text ?? ""
                    
                    if existingPasscode != self?.passcode {
                        errorMsg.append("Existing passcode is invalid.")
                    }
                } else {
                    newPasscode = ac?.textFields?[0].text ?? ""
                    confirmNewPasscode = ac?.textFields?[1].text ?? ""
                }
                
                if newPasscode.isEmpty || confirmNewPasscode.isEmpty || newPasscode != confirmNewPasscode {
                    errorMsg.append("New passcode or confirming passcode is invalid.")
                }
                
                guard errorMsg.isEmpty else {
                    self?.showAlertToSetPasscode(errorMsg: errorMsg.joined(separator: "\n"))
                    return
                }
                
                self?.passcode = newPasscode
                
                self?.enabledPasscodeState = true
            }
        }))
        
        if #available(iOS 16.0, *) {
            ac.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(ac, animated: true)
    }
    
    func showAlertToSetPasscodeIfNoPasscodeWasSetPreviously() {
        // show alert to set passcode if passcode wasn't set previously
        hasPasscode(execute: { [weak self] hasPasscode, passcode in
            if !hasPasscode {
                self?.showAlertToSetPasscode(withoutCancelButton: true)
            }
        })
    }
}
