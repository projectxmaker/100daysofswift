//
//  ViewController.swift
//  Project4
//
//  Created by Pham Anh Tuan on 7/29/22.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    @objc private var webView: WKWebView!
    private var progressView: UIProgressView!
    private let websites = ["vnexpress.net", "zingnews.vn"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOpenPageButtonOnNavigationBar()
        setupToolbarItems()
        loadWebsite(websites[0])
    }
    
    private func setupOpenPageButtonOnNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openPageButtonTapped))
    }
    
    @objc private func openPageButtonTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
        for eachWebsite in websites {
            ac.addAction(UIAlertAction(title: eachWebsite, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.popoverPresentationController?.barButtonItem = navigationController?.navigationItem.rightBarButtonItem
        
        present(ac, animated: true, completion: nil)
    }
    
    private func openPage(_ action: UIAlertAction) {
        guard
            let actionTitle = action.title
        else { return }
        
        loadWebsite(actionTitle)
    }
    
    private func loadWebsite(_ website: String) {
        guard
            let url = URL(string: "https://" + website)
        else { return }
        
        webView.load(URLRequest(url: url))
    }

    private func setupToolbarItems() {
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressBarButton = UIBarButtonItem(customView: progressView)
        
        addObserverForChangesOfWebEstimatedProgress()
        
        toolbarItems = [progressBarButton, spacerButton, refreshButton]
        
        navigationController?.isToolbarHidden = false
    }
    
    // MARK: - Observers
    private func addObserverForChangesOfWebEstimatedProgress() {
        addObserver(self, forKeyPath: #keyPath(webView.estimatedProgress), options: .new, context: nil)
    }
    
    // MARK: - Check Changes Of Web Estimated Progress
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "webView.estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // MARK: - Check To-Be-Loaded Website Is One Of Allowed Websites
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for eachWebsite in websites {
                if host.contains(eachWebsite) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)
    }
}

