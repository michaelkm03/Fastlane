//
//  ConversationOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ConversationRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let conversationID: Int?
    let userID: Int?
    let request: ConversationRequest
    
    required init( request: ConversationRequest ) {
        self.request = request
        self.conversationID = request.conversationID
        self.userID = request.userID
    }
    
    override func main() {
        if let conversationID = self.conversationID where conversationID > 0 {
            requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
        }
    }
    
    func onComplete( results: ConversationRequest.ResultType) {
        guard let conversationID = self.conversationID where !results.isEmpty else {
            return
        }
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let conversation: VConversation = context.v_findOrCreateObject([ "remoteId" : conversationID ])
            var displayOrder = self.request.paginator.displayOrderCounterStart
            var messagesLoaded = [VMessage]()
            for result in results {
                let uniqueElements = [ "remoteId" : result.messageID ]
                let newMessage: VMessage
                if let message: VMessage = context.v_findObjects( uniqueElements ).first {
                    newMessage = message
                } else {
                    newMessage = context.v_createObject()
                    newMessage.populate( fromSourceModel: result )
                }
                if conversation.user == nil {
                    conversation.user = newMessage.sender
                }
                if conversation.postedAt == nil {
                    conversation.postedAt = newMessage.postedAt
                }
                newMessage.displayOrder = displayOrder++
                messagesLoaded.append( newMessage )
            }
            conversation.v_addObjects( messagesLoaded, to: "messages" )
            conversation.lastMessageText = messagesLoaded.first?.text ?? conversation.lastMessageText
            
            context.v_save()
        }
    }
}
