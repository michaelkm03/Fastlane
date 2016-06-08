//
//  ShowFetchedCloseUpOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Fetches a piece of content and shows a close up view containing it.
class ShowFetchedCloseUpOperation: MainQueueOperation {
    
    private let displayModifier: ShowCloseUpDisplayModifier
    private var contentID: String
    private let checkPermissions: Bool
    
    init(contentID: String,
         displayModifier: ShowCloseUpDisplayModifier,
         checkPermissions: Bool = true) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        self.checkPermissions = checkPermissions
        super.init()
    }
    
    override func main() {
        
        defer {
            finishedExecuting()
        }
        
        /// FUTURE: do a new load of the content anyway - do we still need this comment?
        guard !cancelled,
            let userID = VCurrentUser.user()?.remoteId.integerValue else {
                return
        }
        
        let displayModifier = self.displayModifier
        let checkPermissions = self.checkPermissions
        let contentFetchOperation = ContentFetchOperation(
            macroURLString: displayModifier.dependencyManager.contentFetchURL,
            currentUserID: String(userID),
            contentID: contentID
        )
        contentFetchOperation.rechainAfter(self).queue() { results, _, _ in
            guard let content = results?.first as? VContent else {
                return
            }
            
            var nextOperation: MainQueueOperation?
            if checkPermissions {
                nextOperation = ShowPermissionedCloseUpOperation(content: content, displayModifier: displayModifier)
            } else {
                nextOperation = ShowCloseUpOperation(content: content, displayModifier: displayModifier)
            }
            nextOperation?.after(contentFetchOperation).queue()
        }
    }
}

private extension VDependencyManager {
    var contentFetchURL: String {
        return networkResources?.stringForKey("contentFetchURL") ?? ""
    }
}
