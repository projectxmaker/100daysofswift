//
//  ViewController.swift
//  Project4
//
//  Created by Pham Anh Tuan on 7/29/22.
//

import UIKit
import WebKit

class WebDetailViewController: UIViewController, WKNavigationDelegate {

    @objc private var webView: WKWebView!
    private var progressView: UIProgressView!
    var websites: [String] = []
    var defaultWebsite: String?
    
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
        
        if let toBeLoadedWebsite = defaultWebsite {
            loadWebsite(toBeLoadedWebsite)
        }
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
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
        
        let forwardButton = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressBarButton = UIBarButtonItem(customView: progressView)
        
        addObserverForChangesOfWebEstimatedProgress()
        
        toolbarItems = [progressBarButton, spacerButton, backButton, forwardButton, refreshButton]
        
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
        
        // display alert when user clicks on the website that is not allowed
        if navigationAction.navigationType == .linkActivated {
            let ac = UIAlertController(title: "ALERT!", message: "\(url?.host ?? "") is not allowed!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        
        decisionHandler(.cancel)
    }
}

