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
            var displayOrder = self.startingDisplayOrder
            
            let conversation: VConversation = context.v_findOrCreateObject([ "remoteId" : self.conversationID ])
            var messagesLoaded = [VMessage]()
            for result in results {
                let uniqueElements = [ "remoteId" : result.messageID ]
                let message: VMessage = context.v_findOrCreateObject( uniqueElements )
                message.populate( fromSourceModel: result )
                message.displayOrder = displayOrder++
                messagesLoaded.append( message )
            }
            conversation.v_addObjects( messagesLoaded, to: "messages" )
            context.v_save()
            completion()
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func clearResults() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let uniqueElements = [ "remoteId" : self.conversationID ]
            guard let persistentConversation: VConversation = context.v_findObjects(uniqueElements).first else {
                return
            }
            for message in persistentConversation.messages.array as? [VMessage] ?? [] {
                context.deleteObject( message )
            }
            context.v_save()
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                v_format: "conversation.remoteId = %@",
                v_argumentArray: [ self.conversationID ],
                v_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest ) as [VMessage]
        }
    }
}
