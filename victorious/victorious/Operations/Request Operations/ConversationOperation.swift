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
            
            /// Check if the conversation has been flagged (deleted)
            /// If so, exit early and do not fetch the conversation
            let flaggedIDs: [Int] = VFlaggedContent().flaggedContentIdsWithType(.Conversation).flatMap { Int($0) }
            if flaggedIDs.contains(conversationID) {
                self.completionBlock?()
                return
            }
            
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
                newMessage.displayOrder = displayOrder++
                messagesLoaded.append( newMessage )
            }
            conversation.v_addObjects( messagesLoaded, to: "messages" )
            conversation.lastMessageText = messagesLoaded.first?.text ?? conversation.lastMessageText
            
            do {
                try context.save()
            } catch {
                // Because conversations may be deleted by the user at any time, this save may fail.
                // In that case, we catch the error and abandon this context that is trying to parse
                // a conversation already deleted.
            }
            
            let objectID = conversation.objectID
            
            if conversation.user == nil {
                completion()
            }
            else {
                self.persistentStore.mainContext.v_performBlock() { context in
                    self.results = self.fetchResults()
                    self.conversation = context.objectWithID( objectID ) as? VConversation
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
            
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: false) ]
            fetchRequest.predicate = predicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            return results
        }
    }
}
