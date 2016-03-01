//
//  UIViewController+FlaggedContent.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// +FlaggedContent
extension UIViewController {
    
    func v_showFlaggedCommentAlert( completion completion: (Bool->())? = nil ) {
        v_showAlert(
            title: NSLocalizedString( "ReportedTitle", comment:""),
            message: NSLocalizedString( "ReportCommentMessage", comment:""),
            completion: completion
        )
    }
    
    func v_showFlaggedUserAlert( completion completion: (Bool->())? = nil ) {
        v_showAlert(
            title: NSLocalizedString( "ReportedTitle", comment:""),
            message: NSLocalizedString( "ReportUserMessage", comment:""),
            completion: completion
        )
    }
    
    func v_showFlaggedContentAlert( completion completion: (Bool->())? = nil ) {
        v_showAlert(
            title: NSLocalizedString( "ReportedTitle", comment:""),
            message: NSLocalizedString( "ReportContentMessage", comment:""),
            completion: completion
        )
    }
    
    func v_showAlert( title title: String, message: String, completion: (Bool->())? = nil ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .Cancel) { action in
            completion?(true)
        }
        alertController.addAction( cancelAction )
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
