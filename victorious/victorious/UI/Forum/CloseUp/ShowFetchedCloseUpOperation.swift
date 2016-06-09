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
    
    init(contentID: String, displayModifier: ShowCloseUpDisplayModifier, checkPermissions: Bool = true) {
        self.displayModifier = displayModifier
        self.contentID = contentID
        super.init()
    }
    
    override func main() {
        defer {
            finishedExecuting()
        }
        
        guard !cancelled,
            let userID = VCurrentUser.user()?.remoteId.integerValue else {
                return
        }
        
        let displayModifier = self.displayModifier
        let contentFetchOperation = ContentFetchOperation(
            macroURLString: displayModifier.dependencyManager.contentFetchURL,
            currentUserID: String(userID),
            contentID: contentID
        )
        contentFetchOperation.rechainAfter(self).queue() { results, _, _ in
            guard let content = results?.first as? VContent else {
                return
            }
            
            ShowPermissionedCloseUpOperation(content: content, displayModifier: displayModifier).after(contentFetchOperation).queue()
        }
    }
}

private extension VDependencyManager {
    var contentFetchURL: String {
        return networkResources?.stringForKey("contentFetchURL") ?? ""
    }
}
