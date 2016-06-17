//
//  ContentUpvoteToggleOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentUpvoteToggleOperation: FetcherOperation {
    private let contentID: String
    private let upvoteURL: String
    private let unupvoteURL: String
    
    init(contentID: String, upvoteURL: String, unupvoteURL: String) {
        self.contentID = contentID
        self.upvoteURL = upvoteURL
        self.unupvoteURL = unupvoteURL
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let content: VContent = context.v_findObjects(["v_remoteID": self.contentID]).first else {
                return
            }
            
            if content.v_isLikedByCurrentUser == true {
                ContentUnupvoteOperation(
                    contentID: self.contentID,
                    contentUnupvoteURL: self.unupvoteURL
                ).rechainAfter(self).queue()
            }
            else {
                ContentUpvoteOperation(
                    contentID: self.contentID,
                    contentUpvoteURL: self.upvoteURL
                ).rechainAfter(self).queue()
            }
        }
    }
}
