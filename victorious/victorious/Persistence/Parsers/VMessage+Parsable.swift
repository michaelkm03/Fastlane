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
        mediaPath                   = message.mediaURL?.absoluteString ?? ""
        postedAt                    = message.postedAt
        remoteId                    = message.messageID
        text                        = message.text
        isRead                      = message.isRead
        shouldAutoplay              = message.shouldAutoplay
        //mediaWidth                  = message.mediaWidth
        //mediaHeight                 = message.mediaHeight
        //sender                      = message.sender
        //mediaAttachments            = message.mediaAttachments
        //senderUserId                = message.senderUserId
        //thumbnailPath               = message.thumbnailPath
        //notification                = message.notification
        
        if self.sender == nil {
            self.sender = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : message.sender.userID ] ) as VUser
        }
        self.sender.populate(fromSourceModel: message.sender)
    }
}
