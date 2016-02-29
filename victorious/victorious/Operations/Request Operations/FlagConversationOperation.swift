//
//  FlagConversationOperation.swift
//  victorious
//
//  Created by Michael Sena on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagConversationOperation: FetcherOperation {
    
    let conversationID: Int
    
    private let flaggedContent = VFlaggedContent()
    
    init(conversationID: Int, mostRecentMessageID: Int) {
        self.conversationID = conversationID
        super.init()
        
        let remoteOperation = FlagConversationRequestOperation(conversationID: conversationID, mostRecentMessageID: mostRecentMessageID)
        remoteOperation.after(self).queue()
    }
    
    override func main() {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            let uniqueElements = [ "remoteId" : self.conversationID ]
            if let conversation: VConversation = context.v_findObjects(uniqueElements).first {
                context.deleteObject(conversation)
                context.v_save()
            }
        }
        
        // For deletions, force a save to the main context to make sure changes are propagated
        // to calling code (a view controller)
        self.persistentStore.mainContext.v_performBlockAndWait() { context in
            context.v_save()
        }
    }
}

class FlagConversationRequestOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: FlagConversationRequest!
    
    init(conversationID: Int, mostRecentMessageID: Int) {
        self.request = FlagConversationRequest(mostRecentMessageID: mostRecentMessageID)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
