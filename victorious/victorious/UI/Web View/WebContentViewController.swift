//
//  WebContentViewController.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import WebKit

/// This is a lightweight wrapper around WKWebView and provides back/forward navigation buttons if required. 
/// Also, loading HTML strings directly into WKWebView breaks its back-forward list, so we must workaround this 
/// by providing our own logic to handle going back/forward around a loaded HTML page. For now, the VC only handles 
/// the case where loadHTML is only called to load the first page inside the viewcontroller. Subsequent calls to loadHTML
/// may break this functionality. 
class WebContentViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, VBackgroundContainer {
    
    // MARK: - Properties 
    
    fileprivate let webView = WKWebView()
    fileprivate var backButton: UIBarButtonItem?
    fileprivate var forwardButton: UIBarButtonItem?
    fileprivate var cancelButton: UIBarButtonItem?
    fileprivate var initialBaseURL: URL?
    fileprivate var initialHTMLString = ""
    fileprivate let dependencyManager: VDependencyManager
    
    // MARK: - Initialization 
    
    init(shouldShowNavigationButtons: Bool, dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        
        super.init(nibName: nil, bundle: nil)
        
        if (shouldShowNavigationButtons) {
            let backButton = UIBarButtonItem(image: UIImage(named: "browser-back"), style: .plain, target: self, action: #selector(WebContentViewController.backButtonPressed))
            let forwardButton = UIBarButtonItem(image: UIImage(named: "browser-forward"), style: .plain, target: self, action: #selector(WebContentViewController.forwardButtonPressed))
            cancelButton = UIBarButtonItem(image: UIImage(named: "browser-close"), style: .plain, target: self, action: #selector(WebContentViewController.cancelButtonPressed))
            
            self.backButton = backButton
            self.forwardButton = forwardButton
            
            backButton.isEnabled = false
            forwardButton.isEnabled = false
            
            navigationItem.rightBarButtonItems = [forwardButton, backButton]
            navigationItem.leftBarButtonItem = cancelButton
        }
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        webView.backgroundColor = .clear
        webView.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge()
        view.addSubview(webView)
        view.v_addFitToParentConstraints(toSubview: webView)
        
        dependencyManager.addBackground(toBackgroundHost: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideStatusBarActivityIndicator()
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - Configuration 
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    // MARK: - Private Helpers
   
    fileprivate func updateNavigationButtonState() {
        backButton?.isEnabled = webView.canGoBack || !webViewIsDisplayingInitialHTMLString
        forwardButton?.isEnabled = webView.canGoForward
    }
    
    fileprivate func showStatusBarActivityIndicator() {
        NetworkActivityIndicator.sharedInstance().start()
    }
    
    fileprivate func hideStatusBarActivityIndicator() {
        NetworkActivityIndicator.sharedInstance().stop()
    }
    
    // MARK: - External Helpers 
    
    func load(_ htmlString: String, baseURL: URL) {
        initialBaseURL = baseURL
        initialHTMLString = htmlString
        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }
    
    func setFailure(with error: NSError?) {
        hideStatusBarActivityIndicator()
        v_showErrorWithTitle(v_defaultErrorTitle, message: error?.localizedDescription)
    }
    
    // MARK: - Navigation
    
    func backButtonPressed() {
        if webView.canGoBack {
            webView.goBack()
        }
        
        else if !webViewIsDisplayingInitialHTMLString {
            // We've reach the end of the backlist, display the first page again.
            webView.loadHTMLString(initialHTMLString, baseURL: initialBaseURL)
        }
    }
    
    func forwardButtonPressed() {
        
        if let nextItem = webView.backForwardList.item(at: 1) , webViewIsDisplayingInitialHTMLString {
            // When the first page is displayed by the user hitting back, the backforward list doesn't update, so going forward
            // from this page takes the user to the wrong page. So we force the webview to load the first item in the list
            webView.go(to: nextItem)
        }
        
        webView.goForward()
    }
    
    func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    var webViewIsDisplayingInitialHTMLString: Bool {
         if
            let webViewURL = webView.url?.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/")),
            let initialURL = initialBaseURL?.absoluteString
        {
            return webViewURL == initialURL
        }
        
        return false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideStatusBarActivityIndicator()
        updateNavigationButtonState()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideStatusBarActivityIndicator()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showStatusBarActivityIndicator()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideStatusBarActivityIndicator()
    }
    
    // MARK: - WKUIDelegate 
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Check if this is a new window navigation. If it is, load the new window's content in the current web view.
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        // Don't create a new webview since we're reusing the same one
        return nil
    }
}
