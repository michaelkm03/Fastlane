//
//  ConversationOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ConversationOperation: RequestOperation, PaginatedOperation {
    
    let conversationID: Int
    let request: ConversationRequest
    
    convenience init(conversationID: Int) {
        self.init( request: ConversationRequest(conversationID: conversationID) )
    }
    
    required init( request: ConversationRequest ) {
        self.request = request
        self.conversationID = request.conversationID
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( results: ConversationRequest.ResultType, completion:()->() ) {
        guard !results.isEmpty else {
            completion()
            return
        }
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            let conversation: VConversation = context.v_findOrCreateObject([ "remoteId" : self.conversationID ])
            var displayOrder = self.request.paginator.start
            var messagesLoaded = [VMessage]()
            for result in results {
                let uniqueElements = [ "remoteId" : result.messageID ]
                let newMessage: VMessage
                if let message: VMessage = context.v_findObjects( uniqueElements ).first {
                    newMessage = message
                } else {
                    newMessage = context.v_createObject()
                    
                    // Save some performance by only parse when it's a new message
                    newMessage.populate( fromSourceModel: result )
                }
                newMessage.displayOrder = displayOrder++
                messagesLoaded.append( newMessage )
            }
            conversation.v_addObjects( messagesLoaded, to: "messages" )
            
            context.v_save()
            completion()
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func clearResults() {
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                vsdk_format: "conversation.remoteId = %@",
                vsdk_argumentArray: [ self.conversationID ],
                vsdk_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            return results
        }
    }
}
