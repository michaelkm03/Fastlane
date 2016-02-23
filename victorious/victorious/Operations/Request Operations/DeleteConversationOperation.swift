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
    
    let userRemoteID: Int
    
    init(userRemoteID: Int) {
        self.userRemoteID = userRemoteID
    }
    
    override func main() {
        
        let remoteID: Int? = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = [ "user.remoteId" : self.userRemoteID ]
            guard let conversation: VConversation = context.v_findObjects( uniqueElements ).first else {
                return nil
            }
            let remoteId: Int? = conversation.remoteId?.integerValue
            context.deleteObject( conversation )
            context.v_saveAndBubbleToParentContext()
            
            return remoteId
        }
        if let remoteID = remoteID {
            DeleteConversationRemoteOperation(conversationID: remoteID).after( self ).queue()
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
