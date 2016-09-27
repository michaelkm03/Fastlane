//
//  UIViewController+Alert.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Displays an alert using the default error and message strings
    /// with a single action that calls on the completion block.
    func v_showDefaultErrorAlert(_ completion: ((Void) -> ())? = nil) {
        v_showAlert(title: v_defaultErrorTitle, message: v_defaultErrorMessage, completion: completion)
    }
    
    /// Displays an alert with a single action that calls on the completion block.
    func v_showAlert(title: String?, message: String?, completion: ((Void) -> ())? = nil ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .cancel) { action in
            completion?()
        }
        alertController.addAction( cancelAction )
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
