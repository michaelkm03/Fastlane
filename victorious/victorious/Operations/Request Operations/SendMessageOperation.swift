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
    
    struct Parameters {
        let text: String
        let recipientID: Int
        let conversationID: Int
        let mediaAttachment: MediaAttachment?
    }
    
    let request: SendMessageRequest
    let parameters: Parameters
    
    private var newMessageObjectID: NSManagedObjectID?
    private var creationDate: NSDate!
    
    required init( request: SendMessageRequest, parameters: Parameters) {
        self.request = request
        self.parameters = parameters
    }
    
    convenience init?( parameters: Parameters) {
        guard let request = SendMessageRequest(
            recipientID: parameters.recipientID,
            text: parameters.text,
            mediaAttachment: parameters.mediaAttachment) else {
                return nil
        }
        self.init(request: request, parameters: parameters)
    }
    
    override func main() {
        self.creationDate = NSDate()
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = ["remoteId" : self.parameters.conversationID ]
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let conversation: VConversation = context.v_findObjects(uniqueElements).first else {
                    return
            }
            let message: VMessage = context.v_createObject()
            message.conversation = conversation
            message.sender = currentUser
            message.text = self.parameters.text
            message.postedAt = self.creationDate
            message.displayOrder = 0
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
