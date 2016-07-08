//
//  ContentFlagOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentFlagOperation: FetcherOperation {
    private let contentFlagURL: String
    private let contentID: String
    private let flaggedContent = VFlaggedContent()

    init(contentID: String, contentFlagURL: String) {
        self.contentID = contentID
        self.contentFlagURL = contentFlagURL
    }
    
    override func main() {
        guard didConfirmActionFromDependencies else {
            cancel()
            return
        }
        
        flaggedContent.addRemoteId(contentID, toFlaggedItemsWithType: .Content)
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let content: VContent = context.v_findObjects( ["v_remoteID" : self.contentID] ).first else {
                return
            }
            context.deleteObject(content)
        }
        ContentFlagRemoteOperation(contentID: contentID, contentFlagURL: contentFlagURL)?.after(self).queue()
    }

}
