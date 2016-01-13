//
//  MarkConversationReadOperation.swift
//  victorious
//
//  Created by Michael Sena on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class MarkConversationReadOperation: RequestOperation {
    
    let conversationID: Int
    private let request: MarkConversationReadRequest
    
    init(conversationID: Int) {
        self.conversationID = conversationID
        self.request = MarkConversationReadRequest(conversationID: conversationID)
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            let conversation: VConversation = context.v_findOrCreateObject(["remoteId": self.conversationID])
            conversation.isRead = NSNumber(bool: true)
            context.v_save()
        }
        
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
