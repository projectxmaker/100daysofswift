//
//  ScriptListViewController.swift
//  Extension
//
//  Created by Pham Anh Tuan on 8/21/22.
//

import UIKit
import MobileCoreServices

class ScriptListViewController: UITableViewController {

    var scripts = [Script]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Script List"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddNewScriptButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(handleShowPrewrittenScripts))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scripts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScriptCell", for: indexPath)
        let script = scripts[indexPath.row]
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = script.name
        cell.contentConfiguration = contentConfig

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let script = scripts[indexPath.row]
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        
        guard let scriptDetailViewController = storyboard.instantiateViewController(withIdentifier: "ScriptDetail") as? ScriptDetailViewController else { return }
        
        scriptDetailViewController.script = script
        scriptDetailViewController.title = script.name
        
        navigationController?.pushViewController(scriptDetailViewController, animated: true)
    }

    
    // MARK: - Button Prewritten Scripts
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
    
    // MARK: - Button Add New Script
    @objc private func handleAddNewScriptButton() {
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        guard let scriptDetailViewController = storyboard.instantiateViewController(withIdentifier: "ScriptDetail") as? ScriptDetailViewController else { return }
        
        navigationController?.pushViewController(scriptDetailViewController, animated: true)
    }
    
    // MARK: - Extra Funcs
    private func sendToSafariSomething(_ scriptText: String) {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": scriptText]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavascript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavascript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }
    

}
