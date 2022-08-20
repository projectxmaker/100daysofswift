//
//  ActionViewController.swift
//  Extension
//
//  Created by Pham Anh Tuan on 8/20/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet weak var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(handleShowPrewrittenScripts))

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

    @IBAction func done() {
        sendToSafariSomething(script.text ?? "")
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        script.scrollIndicatorInsets = script.contentInset

        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

    @objc private func handleShowPrewrittenScripts() {
        let ac = UIAlertController(title: "Prewritten Scripts", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Alert: Hello world", style: .default, handler: { [weak self] _ in
            self?.showAlertOfHelloWord()
        }))
        
        ac.addAction(UIAlertAction(title: "Go: VnExpress", style: .default, handler: { [weak self] _ in
            self?.redirectToAWebsite("https://vnexpress.net")
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func showAlertOfHelloWord() {
        let scriptText = "alert('Hello World')"
        sendToSafariSomething(scriptText)
    }
    
    private func redirectToAWebsite(_ websiteUrl: String) {
        let scriptText = "document.location.href = '\(websiteUrl)'"
        sendToSafariSomething(scriptText)
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
