//
//  DeleteConversationOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DeleteConversationOperation: RequestOperation {
    
    let request: DeleteConversationRequest
    
    init(conversationID: Int) {
        self.request = DeleteConversationRequest(conversationID: conversationID)
    }
    
    override func main() {
        
        // Make the deletion change optimistically
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = [ "remoteId" : self.request.conversationID ]
            let conversation: VConversation? = context.v_findObjects(uniqueElements).first
            if let conversation = conversation {
                context.deleteObject(conversation)
                context.v_save()
            }
        }
        
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}