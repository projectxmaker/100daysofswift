//
//  DetailViewController.swift
//  Project7
//
//  Created by Pham Anh Tuan on 8/4/22.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    private var webView: WKWebView!
    var detailItem: Petition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground:with:)
        performSelector(onMainThread:with:waitUntilDone:)
        embedWebViewIntoView()
        showPetitionDetail()
    }
    
    private func embedWebViewIntoView() {
        webView = WKWebView()
        view = webView
    }
    
    private func showPetitionDetail() {
        guard let detailItem = detailItem else { return }
        
        let htmlString = """
        <html>
            <head>
                <meta name="viewport" content="widht=devide-width, initial-scale=1">
                <style>
                    body {
                        font-size: 150%
                    }
                </style>
            </head>
        <body>
        \(detailItem.body)
        </body>
        </html>
        """
        
        webView?.loadHTMLString(htmlString, baseURL: nil)
    }
}
