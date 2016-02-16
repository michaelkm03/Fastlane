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
    
    /// Convenience function that allows every view contorller to quickly and consistently show
    /// and error message to the user.
    func v_showErrorWithTitle( title: String?, message: String?) {
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        
        let shouldShowDefaultText = title == nil && message == nil
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.mode = .Text
        progressHUD.userInteractionEnabled = false
        if shouldShowDefaultText {
            progressHUD.labelText = NSLocalizedString( "WereSorry", comment:"" )
            progressHUD.detailsLabelText = NSLocalizedString( "ErrorOccured", comment:"" )
        } else {
            progressHUD.labelText = title
            progressHUD.detailsLabelText = message
        }
        progressHUD.hide(true, afterDelay: 2.0)
    }
}
