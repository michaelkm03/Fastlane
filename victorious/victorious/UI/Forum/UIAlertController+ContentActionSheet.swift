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
    convenience init?(actionsFor content: Content, dependencyManager: VDependencyManager, completion: @escaping (_ action: ContentAlertAction) -> Void) {
        
        guard let id = content.id else {
            return nil
        }
        
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if content.isLikedByCurrentUser {
            addAction(UIAlertAction(
                title: dependencyManager.unlikeTitle,
                style: .default,
                handler: { _ in
                    guard
                        let apiPath = dependencyManager.contentUnupvoteAPIPath,
                        let operation = ContentUnupvoteOperation(apiPath: apiPath, contentID: id)
                    else {
                        return
                    }
                    
                    operation.queue { result in
                        switch result {
                            case .success(_): completion(.unlike)
                            case .failure(_), .cancelled: break
                        }
                    }
                }
            ))
        }
        else {
            addAction(UIAlertAction(
                title: dependencyManager.likeTitle,
                style: .default,
                handler: { _ in
                    guard
                        let apiPath = dependencyManager.contentUpvoteAPIPath,
                        let operation = ContentUpvoteOperation(apiPath: apiPath, contentID: id)
                    else {
                        return
                    }
                    
                    operation.queue { result in
                        switch result {
                            case .success(_): completion(.like)
                            case .failure(_), .cancelled: break
                        }
                    }
                }
            ))
        }
        
        if content.wasCreatedByCurrentUser {
            addAction(UIAlertAction(
                title: dependencyManager.deleteTitle,
                style: .destructive,
                handler: { _ in
                    guard
                        let apiPath = dependencyManager.contentDeleteAPIPath,
                        let operation = ContentDeleteOperation(apiPath: apiPath, contentID: id)
                    else {
                        return
                    }
                    
                    operation.queue { result in
                        switch result {
                            case .success(_): completion(.delete)
                            case .failure(_), .cancelled: break
                        }
                    }
                }
            ))
        }
        else {
            addAction(UIAlertAction(
                title: dependencyManager.flagTitle,
                style: .destructive,
                handler: { _ in
                    guard
                        let apiPath = dependencyManager.contentFlagAPIPath,
                        let operation = ContentFlagOperation(apiPath: apiPath, contentID: id)
                    else {
                        return
                    }
                    
                    operation.queue { result in
                        switch result {
                            case .success(_): completion(.flag)
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
                completion(.cancel)
            }
        ))
    }
}

/// Different actions that can be performed from a `UIAlertController` configured for content actions.
enum ContentAlertAction {
    case like, unlike, delete, flag, cancel
}

private extension VDependencyManager {
    var contentUnupvoteAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "contentUnupvoteURL")
    }
    
    var contentUpvoteAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "contentUpvoteURL")
    }
    
    var contentDeleteAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "contentDeleteURL")
    }
    
    var contentFlagAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "contentFlagURL")
    }
    
    var likeTitle: String {
        return childDependency(forKey: "actions")?.string(forKey: "upvote.text") ?? "LIKE"
    }
    
    var unlikeTitle: String {
        return childDependency(forKey: "actions")?.string(forKey: "unupvote.text") ?? "UNLIKE"
    }
    
    var flagTitle: String {
        return childDependency(forKey: "actions")?.string(forKey: "flag.text") ?? "Report Post"
    }
    
    var deleteTitle: String {
        return childDependency(forKey: "actions")?.string(forKey: "delete.text") ?? "Delete Post"
    }
}
