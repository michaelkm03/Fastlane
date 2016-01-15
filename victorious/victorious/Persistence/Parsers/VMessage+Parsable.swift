//
//  VMessage+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VMessage: PersistenceParsable {
    
    func populate( fromSourceModel message: Message ) {
        remoteId                    = message.messageID
        postedAt                    = message.postedAt
        text                        = message.text ?? text
        isRead                      = message.isRead ?? isRead
        
        // TODO: Find-and-replace mediaPath and thumbnailMediaPath for URL versions like in VComment
        
        if let mediaAttachment = message.mediaAttachment {
            // TODO: Add this, too: mediaType               = mediaAttachment.type.rawValue
            mediaPath               = mediaAttachment.url.absoluteString
            thumbnailPath           = mediaAttachment.thumbnailURL.absoluteString
            mediaWidth              = mediaAttachment.size?.width ?? mediaWidth
            mediaHeight             = mediaAttachment.size?.height ?? mediaHeight
        }
        
        if self.sender == nil {
            self.sender = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : message.sender.userID ] ) as VUser
        }
        self.sender.populate(fromSourceModel: message.sender)
    }
}
