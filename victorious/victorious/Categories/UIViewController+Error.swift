//
//  UIViewController+Error.swift
//  victorious
//
//  Created by Patrick Lynch on 2/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    
    var v_defaultErrorTitle: String {
        return NSLocalizedString("WereSorry", comment:"" )
    }
    
    var v_defaultErrorMessage: String {
        return NSLocalizedString("ErrorOccured", comment:"")
    }
    
    func v_showErrorDefaultError() {
        v_showErrorDefaultError(onView: self.view)
    }
    
    func v_showErrorDefaultError(onView view: UIView) {
        v_showErrorWithTitle(v_defaultErrorTitle, message: v_defaultErrorMessage, onView: view)
    }
    
    func v_showErrorWithTitle(_ title: String?, message: String?) {
        v_showErrorWithTitle(title, message: message, onView: view)
    }
    
    func v_showErrorWithTitle(_ title: String?, message: String?, onView view: UIView) {
        MBProgressHUD.hide(for: view, animated: false)
        
        let customView = UIImageView(image: UIImage(named:"error")!.withRenderingMode(.alwaysTemplate))
        customView.tintColor = UIColor.white
        
        // Future: Get rid of the ! imported from objc
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD.mode = .customView
        progressHUD.margin = 30.0
        progressHUD.customView = customView
        progressHUD.isUserInteractionEnabled = false
        progressHUD.label.text = title
        progressHUD.detailsLabel.text = message
        progressHUD.hide(animated: true, afterDelay: 2.0)
    }
}
