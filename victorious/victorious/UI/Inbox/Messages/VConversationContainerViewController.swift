//
//  VConversationContainerViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

public extension VConversationContainerViewController {
    
    public func sendMessage( text text: String, publishParameters: VPublishParameters?, inConversation conversation: VConversation, completion: (() -> ())? = nil ) {
        guard let recipient = conversation.user else {
            return
        }
        
        let mediaAttachment: MediaAttachment?
        if let publishParameters = publishParameters {
            mediaAttachment = MediaAttachment(publishParameters: publishParameters)
        } else {
            mediaAttachment = nil
        }
        
        let parameters = Message.CreationParameters(
            text: text,
            recipientID: recipient.remoteId.integerValue,
            conversationID: nil,
            mediaAttachment: mediaAttachment
        )
        MessageCreateOperation(creationParameters: parameters).queue() { results in
            completion?()
            self.delegate?.onConversationUpdated( conversation )
        }
    }
    
    public func blockUser() {
        // BlockUserOperation is not supported in 5.0
    }
}
