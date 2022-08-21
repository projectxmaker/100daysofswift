//
//  ActionViewController.swift
//  Extension
//
//  Created by Pham Anh Tuan on 8/20/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ScriptDetailViewController: UIViewController {

    var script: Script?
    var scriptIndex: Int?
    var isCreationProcess = false

    @IBOutlet weak var codeView: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    // MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if scriptIndex == nil {
            script = Script()
            isCreationProcess = true
        } else {
            guard
                let tmpIndex = scriptIndex,
                let tmpScript = loadScriptWithIndex(tmpIndex) else {
                dismiss(animated: true)
                return
            }
            
            script = tmpScript
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(handleTestButtonTapped))

        codeView.text = script?.code
        title = script?.name
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notification.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""

                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isCreationProcess {
            let userInfo = ["script": script ?? Script()]
            let notification = NotificationCenter.default
            notification.post(name: Notification.Name("com.projectxmaker.ScriptExtension.NewScriptIsCreated"), object: nil, userInfo: userInfo)
        } else {
            _ = updateScript(script ?? Script(), at: 0)
        }
    }

    // MARK: - Button Funcs
    
    @IBAction func handleTestButtonTapped() {
        sendToSafariSomething(codeView.text ?? "")
    }

    // MARK: - Extra Funcs
    
    private func loadScripts() -> [Script]? {
        let datastore = UserDefaults.standard
        guard
            let scripts = datastore.array(forKey: "scripts") as? [Script]
        else { return nil }
        
        return scripts
    }
    
    private func saveScripts(_ scripts: [Script]) {
        let datastore = UserDefaults.standard
        datastore.set(scripts, forKey: "scripts")
    }
    
    private func insertScript(_ script: Script, at: Int) -> Bool {
        guard var scripts = loadScripts() else { return false }
        
        scripts.insert(script, at: at)
        saveScripts(scripts)
        return true
    }
    
    private func updateScript(_ script: Script, at: Int) -> Bool {
        guard var scripts = loadScripts() else { return false }
        
        scripts[at] = script
        saveScripts(scripts)
        
        return true
    }
    
    private func loadScriptWithIndex(_ i: Int) -> Script? {
        guard let scripts = loadScripts() else { return nil }
        
        return scripts[i]
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            codeView.contentInset = .zero
        } else {
            codeView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        codeView.scrollIndicatorInsets = codeView.contentInset

        let selectedRange = codeView.selectedRange
        codeView.scrollRangeToVisible(selectedRange)
    }
    
    private func sendToSafariSomething(_ scriptText: String) {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": scriptText]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavascript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavascript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }
}
