//
//  ContentDeleteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentDeleteOperation: FetcherOperation {
    private let contentDeleteURL: String
    private let contentID: String
    private let flaggedContent = VFlaggedContent()
    
    init(contentID: String, contentDeleteURL: String) {
        self.contentID = contentID
        self.contentDeleteURL = contentDeleteURL
    }
    
    override func main() {
        guard didConfirmActionFromDependencies else {
            cancel()
            return
        }
        
        Content.hideContent(withID: contentID)
        
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let content: VContent = context.v_findObjects(["v_remoteID": self.contentID]).first else {
                return
            }
            context.deleteObject(content)
        }
        ContentDeleteRemoteOperation(contentID: contentID, contentDeleteURL: contentDeleteURL)?.after(self).queue()
    }
}
