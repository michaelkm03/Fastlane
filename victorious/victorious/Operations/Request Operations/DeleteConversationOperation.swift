//
//  DeleteConversationOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DeleteConversationOperation: FetcherOperation {
    
    let conversationID: Int
    
    private let flaggedContent = VFlaggedContent()
    
    init(conversationID: Int) {
        self.conversationID = conversationID
        super.init()
        
        let remoteOperation = DeleteConversationRemoteOperation(conversationID: conversationID)
        remoteOperation.queueAfter( self )
    }
    
    override func main() {
        flaggedContent.addRemoteId( String(self.conversationID), toFlaggedItemsWithType: .Conversation)
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = [ "remoteId" : self.conversationID ]
            guard let conversation: VConversation = context.v_findObjects( uniqueElements ).first else {
                return
            }
            context.deleteObject( conversation )
            context.v_save()
        }
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            context.v_save()
        }
    }
}

class DeleteConversationRemoteOperation: RequestOperation {
    
    let request: DeleteConversationRequest
    
    init(conversationID: Int) {
        self.request = DeleteConversationRequest(conversationID: conversationID)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
