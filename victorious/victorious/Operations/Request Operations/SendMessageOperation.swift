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
    let parameters: SendMessageOperation.Parameters
    
    struct Parameters {
        let conversation: VConversation
        let sender: VUser
        let text: String
        let mediaAttachmentType: MediaAttachmentType?
        let mediaURL: NSURL?
        let mediaWidth: Int?
        let mediaHeight: Int?
    }
    
    private var creationDate: NSDate!
    
    required init( request: SendMessageRequest, messageParameters: SendMessageOperation.Parameters) {
        self.request = request
        self.parameters = messageParameters
    }
    
    convenience init?( messageParameters: SendMessageOperation.Parameters) {
        
        guard let request = SendMessageRequest(recipientID: messageParameters.sender.remoteId.integerValue,
            text: messageParameters.text,
            mediaAttachmentType: messageParameters.mediaAttachmentType,
            mediaURL: messageParameters.mediaURL) else {
                return nil
        }
        self.init(request: request, messageParameters: messageParameters)
    }
    
    override func main() {
        self.creationDate = NSDate()
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let message: VMessage = context.v_createObject()
            message.conversation = self.parameters.conversation
            message.sender = self.parameters.sender
            message.text = self.parameters.text
            message.postedAt = self.creationDate
            // TODO: Create local Media asset
            context.v_save()
        }
        
        requestExecutor.executeRequest(request, onComplete: self.onComplete, onError: nil)
    }
    
    func onComplete(result: SendMessageRequest.ResultType, completion: () -> () ) {
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            let uniqueElements = [
                "conversation.remoteId" : result.conversationID,
                "sender" : self.parameters.sender,
                "text" : self.parameters.text,
                "postedAt" : self.creationDate
            ]
            let _: VMessage = context.v_findOrCreateObject( uniqueElements )
            context.v_save()
            completion()
        }
    }
}
