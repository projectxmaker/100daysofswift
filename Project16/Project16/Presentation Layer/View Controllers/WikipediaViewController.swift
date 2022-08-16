//
//  WikipediaViewController.swift
//  Project16
//
//  Created by Pham Anh Tuan on 8/16/22.
//

import UIKit
import WebKit

class WikipediaViewController: UIViewController {

    private var webView: WKWebView!
    var wikipediaUrl = ""
    
    override func loadView() {
        webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUrl()
    }

    // MARK: - Extra Funcs
    private func loadUrl() {
        guard let url = URL(string: wikipediaUrl) else { return }
        webView.load(URLRequest(url: url))
    }
}
