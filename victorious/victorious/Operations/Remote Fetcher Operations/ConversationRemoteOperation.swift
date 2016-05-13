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
            
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            let conversationPredicate = NSPredicate(format: "conversation.remoteId = %i", conversationID)
            let optimisticMessagePredicate = NSPredicate(format: "conversation.remoteId = nil")
            let combinedConversationPredicate = conversationPredicate + optimisticMessagePredicate
            fetchRequest.predicate = combinedConversationPredicate || self.request.paginator.paginatorPredicate
            let existingMessages: [VMessage] = context.v_executeFetchRequest(fetchRequest)
            
            var messagesLoaded: [VMessage] = []
            for result in results {
                guard !existingMessages.contains({ $0.remoteId?.integerValue == result.messageID }) else {
                    continue
                }
                let newMessage: VMessage = context.v_createObject()
                newMessage.populate( fromSourceModel: result )
                if conversation.user == nil {
                    conversation.user = newMessage.sender
                }
                if conversation.postedAt == nil {
                    conversation.postedAt = newMessage.postedAt
                }
                messagesLoaded.append( newMessage )
            }
            
            let allMessages = existingMessages + messagesLoaded
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for message in allMessages.sort({ $0.postedAt > $1.postedAt }) {
                message.displayOrder = displayOrder
                displayOrder += 1
            }
            
            conversation.v_addObjects( messagesLoaded, to: "messages" )
            conversation.lastMessageText = messagesLoaded.first?.text ?? conversation.lastMessageText
            
            context.v_save()
        }
    }
}
