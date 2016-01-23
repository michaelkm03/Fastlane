//
//  ConversationOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

// Because messages may exist without a remoteId, we need to check equality differently:
func ==(lhs: VMessage, rhs: VMessage) -> Bool {
    return lhs.postedAt == rhs.postedAt && lhs.text == rhs.text && lhs.conversation == rhs.conversation
}

final class ConversationOperation: RequestOperation, PaginatedOperation {
    
    let conversationID: Int
    let request: ConversationRequest
    
    var conversation: VConversation?
    
    convenience init(conversationID: Int) {
        self.init( request: ConversationRequest(conversationID: conversationID) )
    }
    
    required init( request: ConversationRequest ) {
        self.request = request
        self.conversationID = request.conversationID
    }
    
    override func main() {
        guard self.conversationID > 0 else {
            return
        }
        
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( results: ConversationRequest.ResultType, completion:()->() ) {
        guard !results.isEmpty else {
            completion()
            return
        }
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            let conversation: VConversation = context.v_findOrCreateObject([ "remoteId" : self.conversationID ])
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
                newMessage.displayOrder = displayOrder++
                messagesLoaded.append( newMessage )
            }
            conversation.v_addObjects( messagesLoaded, to: "messages" )
            
            do {
                try context.save()
            } catch {
                // Because conversations may be deleted by the user at any time, this save may fail.
                // In that case, we catch the error and abandon this context that is trying to parse
                // a conversation already deleted.
            }
            
            let objectID = conversation.objectID
            self.persistentStore.mainContext.v_performBlock() { context in
                self.conversation = context.objectWithID( objectID ) as? VConversation
                completion()
            }
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func clearResults() {}
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let conversation: VConversation = context.v_findObjects([ "remoteId" : self.conversationID ]).first else {
                return []
            }
            
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            let predicate = NSPredicate(
                vsdk_format: "conversation = %@",
                vsdk_argumentArray: [ conversation ],
                vsdk_paginator: self.request.paginator )
            
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            fetchRequest.predicate = predicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            return results
        }
    }
}

class FetchConverationOperation: FetcherOperation {
    
    let userID: Int
    let paginator: NumericPaginator
    
    init( userID: Int, paginator: NumericPaginator = StandardPaginator() ) {
        self.userID = userID
        self.paginator = paginator
    }
    
    override func main() {
        self.results = persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            let predicate = NSPredicate(
                vsdk_format: "conversation.user.remoteId == %@",
                vsdk_argumentArray: [ self.userID ],
                vsdk_paginator: self.paginator )
            
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            fetchRequest.predicate = predicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            return results
        }
    }
}