//
//  ViewController.swift
//  SecretSwift
//
//  Created by Pham Anh Tuan on 9/11/22.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var secret: UITextView!
    var doneButton: UIBarButtonItem!
    var enablePasswordButton: UIBarButtonItem!
    var setPasswordButton: UIBarButtonItem!
    
    var hideDoneButton = true {
        willSet {
            if newValue == true {
                navigationItem.rightBarButtonItem = nil
            } else {
                navigationItem.rightBarButtonItem = doneButton
            }
        }
    }
    
    var hidePasswordButton = true {
        willSet {
            setupVisibilityOfPasswordButtons(hidePasswordButton: newValue, enablePassword: enablePassword)
        }
    }
    
    var enablePassword = false {
        willSet {
            setupVisibilityOfPasswordButtons(hidePasswordButton: hidePasswordButton, enablePassword: newValue)
            KeychainWrapper.standard.set(newValue, forKey: keyIsPasswordEnabled)
        }
    }
    
    let keySecretPassword = "SecrectPassword"
    let keySecretMessage = "SecretMessage"
    let keyIsPasswordEnabled = "IsPasswordEnabled"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)

        
        title = "Nothing to see here"
        
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveSecretMessage))
        
        setupPasswordButtons()
    }
    
    // MARK: - Keyboard Change
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        secret.scrollIndicatorInsets = secret.contentInset

        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    // MARK: - Keychain
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"

        if let text = KeychainWrapper.standard.string(forKey: keySecretMessage) {
            secret.text = text
        }
        
        hideDoneButton = false
        hidePasswordButton = false
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }

        KeychainWrapper.standard.set(secret.text, forKey: keySecretMessage)
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
        
        hideDoneButton = true
        hidePasswordButton = true
    }
    
    // MARK: - IBAction Functions
    @IBAction func authenticateTapped(_ sender: Any) {
        authenticateWithBiometric()
    }
    
    func authenticateWithBiometric() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        if self?.enablePassword == true {
                            ac.addTextField { textfield in
                                textfield.placeholder = "Input password"
                            }
                            ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                                let password = ac?.textFields?[0].text ?? ""
                                self?.evaluateInputtedPassword(password)
                            }))
                            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        } else {
                            ac.addAction(UIAlertAction(title: "Ok", style: .default))
                        }
                        
                        ac.popoverPresentationController?.barButtonItem = self?.navigationItem.rightBarButtonItem
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            if self.enablePassword == true {
                ac.addTextField { textfield in
                    textfield.placeholder = "Input password"
                }
                ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                    let password = ac?.textFields?[0].text ?? ""
                    self?.evaluateInputtedPassword(password)
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            } else {
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
            }
            
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(ac, animated: true)
        }
    }
    
    // MARK: - Password Functions
    func setupPasswordButtons() {
        enablePasswordButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(enablePasswordFeature))
        
        setPasswordButton = UIBarButtonItem(image: UIImage(systemName: "key"), style: .plain, target: self, action: #selector(setPasswordButtonTapped))
        
        if isPasswordEnabled() == true {
            enablePassword = true
        }
    }
    
    func setupVisibilityOfPasswordButtons(hidePasswordButton: Bool, enablePassword: Bool) {
        if hidePasswordButton == false {
            if enablePassword == true {
                enablePasswordButton.image = UIImage(systemName: "lock.slash")
                navigationItem.leftBarButtonItems = [enablePasswordButton, setPasswordButton]
            } else {
                enablePasswordButton.image = UIImage(systemName: "lock")
                navigationItem.leftBarButtonItems = [enablePasswordButton]
            }
        } else {
            navigationItem.leftBarButtonItems = nil
        }
    }
    
    @objc func setPasswordButtonTapped() {
        showAlertToSetPassword()
    }
    
    func showAlertToSetPassword(_ invalidPasswordErrorMsg: String? = "") {
        let ac = UIAlertController(title: "Set Password", message: invalidPasswordErrorMsg ?? nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "New password"
            textfield.isSecureTextEntry = true
        }
        ac.addTextField { textfield in
            textfield.placeholder = "Retype new password"
            textfield.isSecureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
            let password = ac?.textFields?[0].text ?? ""
            let retypedPassword = ac?.textFields?[1].text ?? ""
            
            if password != "" && password == retypedPassword {
                self?.setPassword(password)
            } else {
                self?.showAlertToSetPassword("Password is invalid")
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func setPassword(_ password: String) {
        KeychainWrapper.standard.set(password, forKey: keySecretPassword)
    }
    
    func evaluateInputtedPassword(_ password: String) {
        if let storedPassword = getPassword() {
            if storedPassword == password {
                unlockSecretMessage()
            } else {
                showAlertOfInvalidPassword()
            }
        } else {
            showAlertOfInvalidPassword()
        }
    }
    
    func showAlertOfInvalidPassword() {
        if enablePassword == true {
            let ac = UIAlertController(title: "Invalid Password", message: "Inputted password is incorrect.", preferredStyle: .alert)
            ac.addTextField { textfield in
                textfield.placeholder = "Re-input password"
                textfield.isSecureTextEntry = true
            }
            ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak ac, weak self] _ in
                let password = ac?.textFields?[0].text ?? ""
                self?.evaluateInputtedPassword(password)
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(ac, animated: true)
        }
    }
    
    func getPassword() -> String? {
        KeychainWrapper.standard.string(forKey: keySecretPassword)
    }
    
    @objc func enablePasswordFeature() {
        if enablePassword == false {
            enablePassword = true
        } else {
            enablePassword = false
        }
    }
    
    func isPasswordEnabled() -> Bool? {
        KeychainWrapper.standard.bool(forKey: keyIsPasswordEnabled)
    }
}

