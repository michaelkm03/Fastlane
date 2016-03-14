//
//  MessageCreateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class MessageCreateOperation: FetcherOperation {
    
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
            let remoteOperation = MessageSendRemoteOperation(localMessageID: messageObjectID, creationParameters: self.creationParameters) {
                remoteOperation.after(self).queue()
        }
    }
}
