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
        
        guard let url = URL(string: "https://vnexpress.net") else { return }
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }


}

