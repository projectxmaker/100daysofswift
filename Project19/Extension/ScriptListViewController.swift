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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationNewScriptIsCreated), name: Notification.Name("com.projectxmaker.ScriptExtension.NewScriptIsCreated"), object: nil)

        reloadScriptList()
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
        
        scriptDetailViewController.scriptIndex = indexPath.row
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
    
    @objc private func handleNotificationNewScriptIsCreated(_ notifcation: Notification) {
        guard
            let userInfo = notifcation.userInfo,
            let newScript = userInfo["script"] as? Script
        else { return }
        
        let ac = UIAlertController(title: "Name Your Script", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "New Script \(Date.now.formatted(.dateTime))"
        }
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            var scriptName = "New Script"
            if let inputtedName = ac.textFields?[0].text {
                scriptName = inputtedName
            }
            
            newScript.name = scriptName
            
            _ = self?.insertScript(newScript, at: 0)
            
            self?.reloadScriptList()
            self?.dismiss(animated: true)
        }))
        
        present(ac, animated: true)
    }
    
    private func loadScripts() -> [Script]? {
        let datastore = UserDefaults.standard
        guard
            let encodedData = datastore.data(forKey: "scripts"),
            let decodedData = try? JSONDecoder().decode([Script].self, from: encodedData)
        else { return nil }

        return decodedData
    }
    
    private func saveScripts() {
        guard let encodedData = try? JSONEncoder().encode(scripts) else { return }
        
        let datastore = UserDefaults.standard
        datastore.set(encodedData, forKey: "scripts")
    }
    
    private func insertScript(_ script: Script, at: Int) -> Bool {
        if let tmpScripts = loadScripts() {
            scripts = tmpScripts
        }
        
        scripts.insert(script, at: at)
        saveScripts()
        
        return true
    }
    
    private func reloadScriptList() {
        guard let tmpScripts = loadScripts() else {
            return
        }
        scripts = tmpScripts
        
        tableView.reloadData()
    }
}
