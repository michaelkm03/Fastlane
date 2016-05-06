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
    
    func v_showFlaggedCommentAlert( completion completion: (Void -> ())? = nil ) {
        v_showAlert(
            title: NSLocalizedString( "ReportedTitle", comment: ""),
            message: NSLocalizedString( "ReportCommentMessage", comment: ""),
            completion: completion
        )
    }
    
    func v_showBlockedUserAlert( completion completion: (Void -> ())? = nil ) {
        v_showAlert(
            title: NSLocalizedString( "ReportedTitle", comment: ""),
            message: NSLocalizedString( "ReportUserMessage", comment: ""),
            completion: completion
        )
    }
    
    func v_showFlaggedContentAlert( completion completion: (Void -> ())? = nil ) {
        v_showAlert(
            title: NSLocalizedString( "ReportedTitle", comment: ""),
            message: NSLocalizedString( "ReportContentMessage", comment: ""),
            completion: completion
        )
    }
}
