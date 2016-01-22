//
//  FlagConversationOperation.swift
//  victorious
//
//  Created by Michael Sena on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagConversationOperation: RequestOperation {
    
    let request: FlagConversationRequest
    
    let conversationID: Int
    private let flaggedContent = VFlaggedContent()
    
    init(conversationID: Int, mostRecentMessageID: Int) {
        self.conversationID = conversationID
        self.request = FlagConversationRequest(mostRecentMessageID: mostRecentMessageID)
    }
    
    override func main() {
        flaggedContent.addRemoteId( String(self.conversationID), toFlaggedItemsWithType: .Conversation)
        
        // Perform data changes optimistically
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            let uniqueElements = [ "remoteId" : self.conversationID ]
            if let conversation: VConversation = context.v_findObjects(uniqueElements).first {
                context.deleteObject(conversation)
                context.v_save()
            }
        }
        
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
