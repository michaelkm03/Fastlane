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
    ///
    /// The provided content must have an ID.
    ///
    convenience init?(actionsFor content: ContentModel, dependencyManager: VDependencyManager) {
        guard let id = content.id else {
            return nil
        }
        
        self.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if content.isLikedByCurrentUser {
            addAction(UIAlertAction(
                title: "Unbump",
                style: .Default,
                handler: { alertAction in
                    if let apiPath = dependencyManager.contentUnupvoteAPIPath {
                        ContentUnupvoteOperation(contentID: id, apiPath: apiPath).queue()
                    }
                }
            ))
        }
        else {
            addAction(UIAlertAction(
                title: "Bump",
                style: .Default,
                handler: { alertAction in
                    if let apiPath = dependencyManager.contentUpvoteAPIPath {
                        ContentUpvoteOperation(contentID: id, apiPath: apiPath).queue()
                    }
                }
            ))
        }
        
        if content.wasCreatedByCurrentUser {
            addAction(UIAlertAction(
                title: "Delete",
                style: .Destructive,
                handler: { alertAction in
                    if let apiPath = dependencyManager.contentDeleteAPIPath {
                        ContentDeleteOperation(contentID: id, apiPath: apiPath).queue()
                    }
                }
            ))
        }
        else {
            addAction(UIAlertAction(
                title: "Flag",
                style: .Destructive,
                handler: { alertAction in
                    if let apiPath = dependencyManager.contentFlagAPIPath {
                        ContentFlagOperation(contentID: id, apiPath: apiPath).queue()
                    }
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

private extension VDependencyManager {
    private var contentUnupvoteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentUnupvoteURL")
    }
    
    private var contentUpvoteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentUpvoteURL")
    }
    
    private var contentDeleteAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentDeleteURL")
    }
    
    private var contentFlagAPIPath: APIPath? {
        return networkResources?.apiPathForKey("contentFlagURL")
    }
}
