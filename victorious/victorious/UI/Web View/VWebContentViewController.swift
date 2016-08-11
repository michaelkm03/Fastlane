//
//  VWebContentViewController.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VWebContentViewController {
     func configureNavigationButtons() {
        let backButton = UIBarButtonItem(image: UIImage(named: "banner-next"), style: .Plain, target: self, action: #selector(VWebContentViewController.backButtonPressed))
        let forwardButton = UIBarButtonItem(image: UIImage(named: "browser-back"), style: .Plain, target: self, action: #selector(VWebContentViewController.forwardButtonPressed))
        let cancelButton = UIBarButtonItem(image: UIImage(named: "browser-close"), style: .Plain, target: self, action: #selector(VWebContentViewController.cancelButtonPressed))
        
        navigationItem.rightBarButtonItems = [forwardButton, backButton]
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    public func backButtonPressed() {
        webView.goBack()
    }
    
    func forwardButtonPressed() {
        webView.goForward()
    }
    
    func cancelButtonPressed() {
            dismissSelf()
    }
}
