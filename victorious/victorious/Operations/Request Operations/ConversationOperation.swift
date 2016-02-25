//
//  ConversationOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ConversationOperation: FetcherOperation, PaginatedRequestOperation {
    
    let conversationID: Int?
    let userID: Int?
    let request: ConversationRequest
    
    var conversation: VConversation?
    
    convenience init(conversationID: NSNumber?, userID: NSNumber?) {
        let request = ConversationRequest(
            conversationID: conversationID?.integerValue ?? 0,
            userID: userID?.integerValue
        )
        self.init( request: request )
    }
    
    required init( request: ConversationRequest ) {
        self.request = request
        self.conversationID = request.conversationID
        self.userID = request.userID
    }
    
    override func main() {
        
        // If we have a valid conversationID, reload it remotely first
        if let conversationID = self.conversationID where conversationID > 0 {
            
            requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
            
        } else {
            self.results = self.fetchResults()
        }
    }
    
    func onComplete( results: ConversationRequest.ResultType, completion:()->() ) {
        guard let conversationID = self.conversationID where !results.isEmpty else {
            completion()
            return
        }
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
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
            
            let objectID = conversation.objectID
            
            if conversation.user == nil {
                // If conversation has been deleted
                completion()
            }
            else {
                self.persistentStore.mainContext.v_performBlock() { context in
                    self.results = self.fetchResults()
                    self.conversation = context.objectWithID(objectID) as? VConversation
                    completion()
                }
            }
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let messagesPredicate = self.messagesPredicate else {
                VLog("Unable to load messages without a converationID or userID.")
                assertionFailure()
                return []
            }
            
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: false) ]
            fetchRequest.predicate = self.request.paginator.paginatorPredicate + messagesPredicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            return results
        }
    }
    
    private var messagesPredicate: NSPredicate? {
        if let conversationID = self.conversationID where conversationID > 0 {
            return NSPredicate(format: "conversation.remoteId == %i", conversationID)
            
        } else if let userID = self.userID {
            return NSPredicate(format: "conversation.user.remoteId == %i", userID)
            
        } else {
            return nil
        }
    }
}

final class FetchConverationOperation: FetcherOperation, PaginatedOperation {
    
    let userID: Int
    let paginator: StandardPaginator
    
    required convenience init(operation: FetchConverationOperation, paginator: StandardPaginator) {
        self.init(userID: operation.userID, paginator: paginator)
    }
    
    init( userID: Int, paginator: StandardPaginator = StandardPaginator() ) {
        self.paginator = paginator
        self.userID = userID
    }
    
    override func main() {
        self.results = persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            let predicate = NSPredicate(
                vsdk_format: "conversation.user.remoteId == %@",
                vsdk_argumentArray: [ self.userID ],
                vsdk_paginator: self.paginator )
            
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: false) ]
            fetchRequest.predicate = predicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            return results
        }
    }
}
