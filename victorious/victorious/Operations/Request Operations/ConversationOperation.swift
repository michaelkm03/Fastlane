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
            var displayOrder = self.request.paginator.start
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
            
            context.v_save()
            completion()
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

class FetcherOperation: NSOperation, Queuable {
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    private static let sharedQueue: NSOperationQueue = NSOperationQueue()
    
    private var results = [AnyObject]()
    
    var defaultQueue: NSOperationQueue { return FetcherOperation.sharedQueue }
    
    var mainQueueCompletionBlock: (([AnyObject])->())?
    
    func queueOn( queue: NSOperationQueue, completionBlock:(([AnyObject])->())?) {
        self.completionBlock = {
            if completionBlock != nil {
                self.mainQueueCompletionBlock = completionBlock
            }
            dispatch_async( dispatch_get_main_queue()) {
                self.mainQueueCompletionBlock?(self.results)
            }
        }
        queue.addOperation( self )
    }
}

class FetchConverationListOperation: FetcherOperation {
    
    let userID: Int
    let paginator: NumericPaginator
    
    init( userID: Int, paginator: NumericPaginator = StandardPaginator() ) {
        self.userID = userID
        self.paginator = paginator
    }
    
    override func main() {
        self.results = persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                vsdk_format: "",
                vsdk_argumentArray: [],
                vsdk_paginator: self.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest ) as [VConversation]
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

class CreateMessageOperation: FetcherOperation {
    
    let creationParameters: Message.CreationParameters
    
    private var creationDate: NSDate!
    
    init(creationParameters: Message.CreationParameters) {
        self.creationParameters = creationParameters
    }
    
    override func main() {
        self.creationDate = NSDate()
        
        let newMessageObjectID: NSManagedObjectID? = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            let uniqueElements = [ "user.remoteId" : self.creationParameters.recipientID ]
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let conversation: VConversation = context.v_findObjects(uniqueElements).first else {
                    return nil
            }
            
            // Gather "local messages", those that have been created locally but not yet given
            // a remoteId in the response to the remote network request
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            fetchRequest.predicate = NSPredicate(
                format: "conversation.remoteId = %@ && remoteId = nil",
                argumentArray: [ self.creationParameters.conversationID ]
            )
            // Start counting display order into negatives so that all messages appear first2
            let localMessages = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            let displayOrder = -localMessages.count
            
            let message: VMessage = context.v_createObject()
            message.sender = currentUser
            message.senderUserId = currentUser.remoteId
            message.text = self.creationParameters.text
            message.postedAt = self.creationDate
            message.displayOrder = displayOrder
            
            if let mediaAttachment = self.creationParameters.mediaAttachment {
                message.mediaType = mediaAttachment.type.rawValue
                message.mediaUrl = mediaAttachment.url.absoluteString
                message.thumbnailUrl = mediaAttachment.thumbnailURL.absoluteString
                message.mediaWidth = mediaAttachment.size?.width
                message.mediaHeight = mediaAttachment.size?.height
            }
            
            conversation.lastMessageText = message.text
            conversation.postedAt = conversation.postedAt ?? self.creationDate
            conversation.v_addObject(message, to: "messages")
            context.v_save()
            
            return message.objectID
        }
        
        if let messageObjectID = newMessageObjectID,
            let remoteOperation = SendMessageOperation(localMessageID: messageObjectID, creationParameters: self.creationParameters) {
                remoteOperation.queueAfter(self)
        }
    }
}
