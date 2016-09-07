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
                title: dependencyManager.unlikeTitle,
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
                title: dependencyManager.likeTitle,
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
                title: dependencyManager.deleteTitle,
                style: .Destructive,
                handler: { _ in
                    guard let apiPath = dependencyManager.contentDeleteAPIPath else {
                        return
                    }
                    
                    ContentDeleteOperation(contentID: id, apiPath: apiPath).queue { result in
                        switch result {
                            case .success(_): completion(action: .delete)
                            case .failure(_), .cancelled: break
                        }
                    }
                }
            ))
        }
        else {
            addAction(UIAlertAction(
                title: dependencyManager.flagTitle,
                style: .Destructive,
                handler: { _ in
                    guard let apiPath = dependencyManager.contentFlagAPIPath else {
                        return
                    }
                    
                    ContentFlagOperation(contentID: id, apiPath: apiPath).queue { result in
                        switch result {
                            case .success(_): completion(action: .flag)
                            case .failure(_), .cancelled: break
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
    
    private var likeTitle: String {
        return childDependencyForKey("actions")?.stringForKey("upvote.text") ?? "BUMP"
    }
    
    private var unlikeTitle: String {
        return childDependencyForKey("actions")?.stringForKey("unupvote.text") ?? "UNBUMP"
    }
    
    private var flagTitle: String {
        return childDependencyForKey("actions")?.stringForKey("flag.text") ?? "Report Post"
    }
    
    private var deleteTitle: String {
        return childDependencyForKey("actions")?.stringForKey("delete.text") ?? "Delete Post"
    }
}
