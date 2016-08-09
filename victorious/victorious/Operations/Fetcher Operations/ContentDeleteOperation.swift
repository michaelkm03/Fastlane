//
//  ContentDeleteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentDeleteOperation: FetcherOperation {
    private let contentID: Content.ID
    private let apiPath: APIPath
    private let flaggedContent = VFlaggedContent()
    
    init(contentID: Content.ID, apiPath: APIPath) {
        self.contentID = contentID
        self.apiPath = apiPath
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
        ContentDeleteRemoteOperation(contentID: contentID, apiPath: apiPath)?.after(self).queue()
    }
}
