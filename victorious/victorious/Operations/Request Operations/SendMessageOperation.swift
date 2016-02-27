//
//  SendMessageOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SendMessageOperation: FetcherOperation, RequestOperation {
    
    let request: SendMessageRequest!
    let localMessageID: NSManagedObjectID
    
    required init( request: SendMessageRequest, localMessageID: NSManagedObjectID) {
        self.request = request
        self.localMessageID = localMessageID
    }
    
    convenience init?(localMessageID: NSManagedObjectID, creationParameters: Message.CreationParameters) {
        guard let request = SendMessageRequest(creationParameters: creationParameters) else {
            return nil
        }
        self.init(request: request, localMessageID: localMessageID)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(result: SendMessageRequest.ResultType, completion: () -> () ) {
        persistentStore.createBackgroundContext().v_performBlock() { context in
            guard let message = context.objectWithID( self.localMessageID ) as? VMessage else {
                completion()
                return
            }
            message.conversation.remoteId = result.conversationID
            message.remoteId = result.messageID
            context.v_save()
            completion()
        }
    }
}

class CreateMessageOperation: FetcherOperation {
    
    let creationParameters: Message.CreationParameters
    
    init(creationParameters: Message.CreationParameters) {
        self.creationParameters = creationParameters
    }
    
    override func main() {
        
        // Optimistically create a comment before sending request
        let newMessageObjectID: NSManagedObjectID? = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            let uniqueElements = [ "user.remoteId" : self.creationParameters.recipientID ]
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let conversation: VConversation = context.v_findObjects(uniqueElements).first else {
                    return nil
            }
            
            let creationDate = NSDate()
            
            let predicate = NSPredicate( format: "conversation.user.remoteId == %@", argumentArray: [self.creationParameters.recipientID])
            
            let newDisplayOrder = context.v_displayOrderForNewObjectWithEntityName(VMessage.v_entityName(), predicate: predicate)
            
            let message: VMessage = context.v_createObject()
            message.sender = currentUser
            message.text = self.creationParameters.text
            message.postedAt = creationDate
            message.displayOrder = newDisplayOrder
            
            if let mediaAttachment = self.creationParameters.mediaAttachment,
                let thumbnailURL = mediaAttachment.createThumbnailImage() {
                    message.mediaType = mediaAttachment.type.rawValue
                    message.shouldAutoplay = mediaAttachment.type == .GIF ? true : false
                    message.mediaUrl = mediaAttachment.url.absoluteString
                    message.thumbnailUrl = thumbnailURL.absoluteString
                    message.mediaWidth = mediaAttachment.size?.width
                    message.mediaHeight = mediaAttachment.size?.height
            }
            
            let newConversationDisplayOrder = context.v_displayOrderForNewObjectWithEntityName(VConversation.v_entityName())
            conversation.lastMessageText = message.text
            conversation.postedAt = conversation.postedAt ?? creationDate
            conversation.v_addObject(message, to: "messages")
            conversation.displayOrder = newConversationDisplayOrder
            context.v_save()
            
            return message.objectID
        }
        
        if let messageObjectID = newMessageObjectID,
            let remoteOperation = SendMessageOperation(localMessageID: messageObjectID, creationParameters: self.creationParameters) {
                remoteOperation.after(self).queue()
        }
    }
}