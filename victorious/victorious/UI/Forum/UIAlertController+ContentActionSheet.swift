//
//  UIAlertController+ContentActionSheet.swift
//  victorious
//
//  Created by Jarod Long on 8/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIAlertController {
    /// Creates an alert controller configured to show actions to take on an individual piece of content like flagging
    /// or liking.
    convenience init(actionsFor content: ContentModel) {
        self.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        addAction(UIAlertAction(
            title: "Bump",
            style: .Default,
            handler: { alertAction in
                print("bump")
            }
        ))
        
        if content.wasCreatedByCurrentUser {
            addAction(UIAlertAction(
                title: "Delete",
                style: .Destructive,
                handler: { alertAction in
                    print("delete")
                }
            ))
        }
        else {
            addAction(UIAlertAction(
                title: "Flag",
                style: .Destructive,
                handler: { alertAction in
                    print("flag")
                }
            ))
        }
        
        addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .Cancel,
            handler: { _ in }
        ))
    }
}
