//
//  VConversationContainerViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public extension VConversationContainerViewController {
    
    public func sendMessage( text text: String, inConversation conversation: VConversation, completion:((NSError?)->())? = nil ) {
        guard let recipient = conversation.user else {
            return
        }
        
        let parameters = SendMessageOperation.Parameters(
            text: text,
            recipientID: recipient.remoteId.integerValue,
            conversationID: conversation.remoteId.integerValue,
            mediaAttachment: nil
        )
        SendMessageOperation(parameters: parameters)?.queue() { error in
            completion?(error)
        }
    }
}
