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
    
    var unreadConversationsCount: NSNumber?
    
    init(conversationID: Int) {
        self.conversationID = conversationID
        self.request = MarkConversationReadRequest(conversationID: conversationID)
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            guard let conversation: VConversation = context.v_findObjects( ["remoteId": self.conversationID] ).first else {
                return
            }
            conversation.isRead = true
            context.v_save()
        }
        
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(result: Int?, completion: () -> () ) {
        if let unreadConversationsCount = result {
            self.unreadConversationsCount = unreadConversationsCount
        }
        completion()
    }
}
