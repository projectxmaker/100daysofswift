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
    private var progressView = UIProgressView(progressViewStyle: .default)
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOpenPageButtonOnNavigationBar()
        setupToolbarItems()
    }
    
    private func setupOpenPageButtonOnNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openPageButtonTapped))
    }
    
    @objc private func openPageButtonTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "vnexpress.net", style: .default, handler: openPage))
        ac.addAction(UIAlertAction(title: "news.zing.vn", style: .default, handler: openPage))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.popoverPresentationController?.barButtonItem = navigationController?.navigationItem.rightBarButtonItem
        
        present(ac, animated: true, completion: nil)
    }
    
    private func openPage(_ action: UIAlertAction) {
        guard
            let actionTitle = action.title,
            let url = URL(string: "https://" + actionTitle)
        else { return }
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    private func setupToolbarItems() {
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
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
}

