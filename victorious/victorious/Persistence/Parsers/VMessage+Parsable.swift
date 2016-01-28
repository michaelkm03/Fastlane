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
        
        if let mediaAttachment = message.mediaAttachment {
            mediaType               = mediaAttachment.type.rawValue
            mediaUrl                = mediaAttachment.url.absoluteString
            thumbnailUrl            = mediaAttachment.thumbnailURL?.absoluteString ?? thumbnailUrl
            mediaWidth              = mediaAttachment.size?.width ?? mediaWidth
            mediaHeight             = mediaAttachment.size?.height ?? mediaHeight
            shouldAutoplay          = mediaAttachment.shouldAutoplay
            
            // We MUST use the MP4 asset for gifs
            if mediaAttachment.type == .GIF {
                mediaUrl = mediaAttachment.MP4URLForMediaAttachment()?.absoluteString
            }
        }
        
        if let messageSender = message.sender {
            if self.sender == nil {
                self.sender = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : messageSender.userID ] ) as VUser
            }
            self.sender.populate(fromSourceModel: messageSender)
        }
    }
}
