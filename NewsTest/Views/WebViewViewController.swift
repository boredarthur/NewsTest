//
//  WebViewViewController.swift
//  NewsTest
//
//  Created by boredarthur on 18.01.2022.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    
    // MARK: - Properties
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    private let url: URL
    
    // MARK: - Init
    init(url: URL, title: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.load(URLRequest(url: url))
        configureButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    // MARK: - Setting up buttons for navigation
    private func configureButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefresh))
    }
    
    // MARK: - On Done button tapped
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - On Refresh button tapped
    @objc private func didTapRefresh() {
        webView.load(URLRequest(url: url))
    }
}
