//
//  WebContentViewController.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import WebKit

class WebContentViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    // MARK: - Properties 
    
    private let webView = WKWebView()
    private var backButton: UIBarButtonItem?
    private var forwardButton: UIBarButtonItem?
    private var cancelButton: UIBarButtonItem?
    private var initialBaseURL: NSURL?
    private var initialHTMLString = ""
    
    // MARK: - Initialization 
    
    init(shouldShowNavigationButtons: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        if (shouldShowNavigationButtons) {
            let backButton = UIBarButtonItem(image: UIImage(named: "browser-back"), style: .Plain, target: self, action: #selector(WebContentViewController.backButtonPressed))
            let forwardButton = UIBarButtonItem(image: UIImage(named: "banner_next"), style: .Plain, target: self, action: #selector(WebContentViewController.forwardButtonPressed))
            cancelButton = UIBarButtonItem(image: UIImage(named: "browser-close"), style: .Plain, target: self, action: #selector(WebContentViewController.cancelButtonPressed))
            
            self.backButton = backButton
            self.forwardButton = forwardButton
            
            navigationItem.rightBarButtonItems = [forwardButton, backButton]
            navigationItem.leftBarButtonItem = cancelButton
            updateNavigationButtonState()
        }
        
        webView.navigationDelegate = self
        webView.UIDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.backgroundColor = UIColor.whiteColor()
        view.addSubview(webView)
        view.v_addFitToParentConstraintsToSubview(webView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        webView.stopLoading()
        webView.navigationDelegate = nil
        hideStatusBarActivityIndicator()
    }
    
    // MARK: - Configuration 
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    // MARK: - Private Helpers
   
    private func updateNavigationButtonState() {
        backButton?.enabled = webView.canGoBack || !webViewIsDisplayingInitialHTMLString
        forwardButton?.enabled = webView.canGoForward
    }
    
    private func showStatusBarActivityIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    private func hideStatusBarActivityIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - External Helpers 
    
    func load(htmlString: String, baseURL: NSURL) {
        initialBaseURL = baseURL
        initialHTMLString = htmlString
        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }
    
    func setFailure(withError error: NSError?) {
        hideStatusBarActivityIndicator()
    }
    
    // MARK: - Navigation
    
    func backButtonPressed() {
        if webView.canGoBack {
            webView.goBack()
        }
        
        else if !webViewIsDisplayingInitialHTMLString {
            webView.loadHTMLString(initialHTMLString, baseURL: initialBaseURL)
        }
    }
    
    func forwardButtonPressed() {
        webView.goForward()
    }
    
    func cancelButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var webViewIsDisplayingInitialHTMLString: Bool {
         if
            let webViewURL =  webView.URL?.absoluteString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/")),
            let initialURL = initialBaseURL?.absoluteString
        {
                return webViewURL == initialURL
        }
        
        return false
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        hideStatusBarActivityIndicator()
        updateNavigationButtonState()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        hideStatusBarActivityIndicator()
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showStatusBarActivityIndicator()
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        hideStatusBarActivityIndicator()
    }
    
    // MARK: - WKUIDelegate 
    
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //Check if this is a new window navigation. If it is, load the new window's content in the current web view.
        if navigationAction.targetFrame == nil {
            webView.loadRequest(navigationAction.request)
        }
        //Don't create a new webview since we're reusing the same one
        return nil
    }
}
        