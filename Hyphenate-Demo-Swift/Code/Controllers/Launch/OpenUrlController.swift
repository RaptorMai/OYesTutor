//
//  OpenUrlController.swift
//  Hyphenate Messenger
//
//  Created by Yi Jerry on 2017-09-20.
//  Copyright © 2017 Hyphenate Inc. All rights reserved.
//

import UIKit
import WebKit

class OpenUrlViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var url : String?
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.addSubview(webView)
        let myURL = URL(string: url!)
        let myRequest = URLRequest(url: myURL!)
        
        webView.load(myRequest)
    }
    
    // MARK: - Navigation Bar and Tab Bar
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Help"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.addSubview(progressView)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressView.removeFromSuperview()
        
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        
        // Progress Bar
        webView.navigationDelegate = self
        progressView = UIProgressView(frame: CGRect(x: 0, y: 44-2, width: UIScreen.main.bounds.size.width, height: 2))
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = UIColor.orange
        progressView.tag = 1
        self.navigationController?.navigationBar.addSubview(progressView)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        
        view = webView
    }
    
    // MARK: - Progress Bar
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            print(webView.estimatedProgress)
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
        self.navigationItem.title = webView.title
    }
    
    deinit {
        print("con is deinit")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        progressView.reloadInputViews()
    }
  
    
}

