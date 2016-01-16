//
//  SendMessageOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SendMessageOperation: RequestOperation {
    
    let request: SendMessageRequest
    let creationParameters: Message.CreationParameters
    
    private var newMessageObjectID: NSManagedObjectID?
    private var creationDate: NSDate!
    
    required init( request: SendMessageRequest, creationParameters: Message.CreationParameters) {
        self.request = request
        self.creationParameters = creationParameters
    }
    
    convenience init?( creationParameters: Message.CreationParameters) {
        guard let request = SendMessageRequest(creationParameters: creationParameters) else {
                return nil
        }
        self.init(request: request, creationParameters: creationParameters)
    }
    
    override func main() {
        self.creationDate = NSDate()
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = ["remoteId" : self.creationParameters.conversationID ]
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let conversation: VConversation = context.v_findObjects(uniqueElements).first else {
                    return nil
            }
            
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            fetchRequest.predicate = NSPredicate(
                format: "conversation.remoteId = %@ && remoteId = nil",
                argumentArray: [ self.creationParameters.conversationID ]
            )
            let localMessages = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            
            let message: VMessage = context.v_createObject()
            message.sender = currentUser
            message.senderUserId = currentUser.remoteId
            message.text = self.creationParameters.text
            message.postedAt = self.creationDate
            message.displayOrder = -localMessages.count
            
            if let mediaAttachment = self.creationParameters.mediaAttachment {
                message.mediaType = mediaAttachment.type.rawValue
                message.mediaUrl = mediaAttachment.url.absoluteString
                message.thumbnailUrl = mediaAttachment.thumbnailURL.absoluteString
                message.mediaWidth = mediaAttachment.size?.width
                message.mediaHeight = mediaAttachment.size?.height
            }
            
            conversation.v_addObject(message, to: "messages")
            context.v_save()
            
            self.newMessageObjectID = message.objectID
            return context
        }
        
        requestExecutor.executeRequest(request, onComplete: self.onComplete, onError: nil)
    }
    
    func onComplete(result: SendMessageRequest.ResultType, completion: () -> () ) {
        
        if let objectID = self.newMessageObjectID {
            let operation = PopulateRemoteMessageOperation(objectID:
                objectID, remoteID:
                result.messageID,
                conversationID: result.conversationID)
            operation.queueAfter(self)
        }
        
        completion()
    }
}

class PopulateRemoteMessageOperation: Operation {
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    let objectID: NSManagedObjectID
    let remoteID: Int
    let conversationID: Int
    
    required init(objectID: NSManagedObjectID, remoteID: Int, conversationID: Int) {
        self.objectID = objectID
        self.remoteID = remoteID
        self.conversationID = conversationID
    }
    
    override func start() {
        super.start()
        
        self.beganExecuting()
        
        // Use the same backgroudn context used to create the message
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let message = context.objectWithID(self.objectID) as? VMessage else {
                self.finishedExecuting()
                return
            }
            message.remoteId = self.remoteID
            context.v_save()
            
            self.finishedExecuting()
        }
    }
}
