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
            
            let uniqueElements = [ "user.remoteId" : self.creationParameters.recipientID ]
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
            
            conversation.lastMessageText = message.text
            conversation.postedAt = conversation.postedAt ?? self.creationDate
            conversation.v_addObject(message, to: "messages")
            context.v_save()
            
            self.newMessageObjectID = message.objectID
            return context
        }
        
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(result: SendMessageRequest.ResultType, completion: () -> () ) {
        guard let objectID = self.newMessageObjectID else {
            completion()
            return
        }
        storedBackgroundContext?.v_performBlock() { context in
            guard let message = context.objectWithID(objectID) as? VMessage else {
                completion()
                return
            }
            message.remoteId = result.messageID
            context.v_save()
            completion()
        }
    }
}
