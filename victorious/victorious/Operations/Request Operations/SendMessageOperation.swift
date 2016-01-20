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
            message.remoteId = result.messageID
            context.v_save()
            completion()
        }
    }
}
