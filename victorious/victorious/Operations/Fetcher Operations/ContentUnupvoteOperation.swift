//
//  ContentUnupvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentUnupvoteOperation: FetcherOperation {
    private let contentUnupvoteURL: String
    private let contentID: String
    
    init(contentID: String, contentUnupvoteURL: String) {
        self.contentID = contentID
        self.contentUnupvoteURL = contentUnupvoteURL
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let content: VContent = context.v_findObjects(["v_remoteID": self.contentID]).first else {
                return
            }
            
            content.v_isLikedByCurrentUser = false
            context.v_save()
        }
        
        ContentUnupvoteRemoteOperation(
            contentID: contentID,
            contentUnupvoteURL: contentUnupvoteURL
        )?.after(self).queue()
    }
}
