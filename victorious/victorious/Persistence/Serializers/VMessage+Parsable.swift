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
        remoteId                    = Int(message.messageID)
        //senderUserId                = message.senderUserId
        text                        = message.text
        //thumbnailPath               = message.thumbnailPath
        isRead                      = message.isRead
        //conversation                = message.conversation
        //notification                = message.notification
        //sender                      = message.sender
        //mediaAttachments            = message.mediaAttachments
        shouldAutoplay              = message.shouldAutoplay
        //mediaWidth                  = message.mediaWidth
        //mediaHeight                 = message.mediaHeight
    }
}
