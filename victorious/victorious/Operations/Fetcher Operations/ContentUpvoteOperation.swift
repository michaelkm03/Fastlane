//
//  ContentUpvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentUpvoteOperation: FetcherOperation {
    private let contentUpvoteURL: String
    private let contentID: String
    
    init(contentID: String, contentUpvoteURL: String) {
        self.contentID = contentID
        self.contentUpvoteURL = contentUpvoteURL
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let content: VContent = context.v_findObjects(["v_remoteID": self.contentID]).first else {
                    return
            }
            
            content.v_isLikedByCurrentUser = true
            context.v_save()
        }
        
        ContentUpvoteRemoteOperation(
            contentID: contentID,
            contentUpvoteURL: contentUpvoteURL
        )?.after(self).queue()
    }
}
