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
    convenience init?(actionsFor content: ContentModel, dependencyManager: VDependencyManager, completion: (action: ContentAlertAction) -> Void) {
        guard let id = content.id else {
            return nil
        }
        
        self.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if content.isLikedByCurrentUser {
            addAction(UIAlertAction(
                title: "Unbump",
                style: .Default,
                handler: { _ in
                    guard let apiPath = dependencyManager.contentUnupvoteAPIPath else {
                        return
                    }
                    
                    ContentUnupvoteOperation(contentID: id, apiPath: apiPath).queue { _, error, _ in
                        if error == nil {
                            completion(action: .unlike)
                        }
                    }
                }
            ))
        }
        else {
            addAction(UIAlertAction(
                title: "Bump",
                style: .Default,
                handler: { _ in
                    guard let apiPath = dependencyManager.contentUpvoteAPIPath else {
                        return
                    }
                    
                    ContentUpvoteOperation(contentID: id, apiPath: apiPath).queue { _, error, _ in
                        if error == nil {
                            completion(action: .like)
                        }
                    }
                }
            ))
        }
        
        if content.wasCreatedByCurrentUser {
            addAction(UIAlertAction(
                title: "Delete",
                style: .Destructive,
                handler: { _ in
                    guard let apiPath = dependencyManager.contentDeleteAPIPath else {
                        return
                    }
                    
                    ContentDeleteOperation(contentID: id, apiPath: apiPath).queue { _, error, _ in
                        if error == nil {
                            completion(action: .delete)
                        }
                    }
                }
            ))
        }
        else {
            addAction(UIAlertAction(
                title: "Flag",
                style: .Destructive,
                handler: { _ in
                    guard let apiPath = dependencyManager.contentFlagAPIPath else {
                        return
                    }
                    
                    ContentFlagOperation(contentID: id, apiPath: apiPath).queue { _, error, _ in
                        if error == nil {
                            completion(action: .flag)
                        }
                    }
                }
            ))
        }
        
        addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .Cancel,
            handler: { _ in
                completion(action: .cancel)
            }
        ))
    }
}

/// Different actions that can be performed from a `UIAlertController` configured for content actions.
enum ContentAlertAction {
    case like, unlike, delete, flag, cancel
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
