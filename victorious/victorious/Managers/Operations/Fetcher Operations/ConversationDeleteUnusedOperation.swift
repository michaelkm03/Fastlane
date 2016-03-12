//
//  ConversationDeleteUnusedOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Deletes the provided conversation if there are no messages
class ConversationDeleteUnusedOperation: FetcherOperation {
    
    private let userID: Int
    
    required init(userID: Int) {
        self.userID = userID
    }
    
    override func main() {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            guard let conversation: VConversation = context.v_findObjects( [ "user.remoteId" : self.userID ] ).first else {
                return
            }
            
            guard let messages = conversation.messages where messages.count == 0 else {
                return
            }
            
            context.deleteObject(conversation)
            context.v_save()
            self.persistentStore.mainContext.v_performBlockAndWait() { context in
                context.v_save()
            }
        }
    }
}
