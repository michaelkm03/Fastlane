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
        v_showErrorWithTitle( v_defaultErrorTitle, message: v_defaultErrorMessage )
    }
    
    func v_showErrorWithTitle(title: String?, message: String?) {
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        
        let customView = UIImageView(image: UIImage(named:"error")!.imageWithRenderingMode(.AlwaysTemplate))
        customView.tintColor = UIColor.whiteColor()
        
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.mode = .CustomView
        progressHUD.margin = 30.0
        progressHUD.customView = customView
        progressHUD.userInteractionEnabled = false
        progressHUD.labelText = title
        progressHUD.detailsLabelText = message
        progressHUD.hide(true, afterDelay: 2.0)
    }
}
