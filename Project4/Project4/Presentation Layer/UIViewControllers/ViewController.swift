//
//  ViewController.swift
//  Project4
//
//  Created by Pham Anh Tuan on 7/29/22.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    private var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOpenPageButtonOnNavigationBar()
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


}

