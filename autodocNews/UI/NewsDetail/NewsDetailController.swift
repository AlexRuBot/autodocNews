//
//  NewsDetailController.swift
//  autodocNews
//
//  Created by Александр Гужавин on 16.01.2025.
//

import UIKit
import WebKit

class NewsDetailController: UIViewController {

    
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    
    var urlString: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Constants.NavigationTitle.newsDetails
        
        webView = WKWebView(frame: self.view.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

extension NewsDetailController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}
