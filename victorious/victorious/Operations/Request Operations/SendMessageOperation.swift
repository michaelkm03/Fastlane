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
        guard let request = SendMessageRequest(
            recipientID: creationParameters.recipientID,
            text: creationParameters.text,
            mediaAttachment: creationParameters.mediaAttachment) else {
                return nil
        }
        self.init(request: request, creationParameters: creationParameters)
    }
    
    override func main() {
        self.creationDate = NSDate()
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = ["remoteId" : self.creationParameters.conversationID ]
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let conversation: VConversation = context.v_findObjects(uniqueElements).first else {
                    return
            }
            let message: VMessage = context.v_createObject()
            message.conversation = conversation
            message.sender = currentUser
            message.text = self.creationParameters.text
            message.postedAt = self.creationDate
            message.displayOrder = 0
            
            if let mediaAttachment = self.creationParameters.mediaAttachment {
                // TODO: Add this, too: mediaType               = mediaAttachment.type.rawValue
                message.mediaPath               = mediaAttachment.url.absoluteString
                message.thumbnailPath           = mediaAttachment.thumbnailURL.absoluteString
                message.mediaWidth              = mediaAttachment.size?.width
                message.mediaHeight             = mediaAttachment.size?.height
            }
            context.v_save()
            
            self.newMessageObjectID = message.objectID
        }
        
        requestExecutor.executeRequest(request, onComplete: self.onComplete, onError: nil)
    }
    
    func onComplete(result: SendMessageRequest.ResultType, completion: () -> () ) {
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            defer { completion() }
            
            guard let objectID = self.newMessageObjectID,
                let message = context.objectWithID(objectID) as? VMessage else {
                    return
            }
            message.remoteId = result.messageID
            context.v_save()
        }
    }
}
