//
//  VPublishParameters+ConvenienceInit.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VPublishParameters {
    
    convenience init?(chatMessage: ChatMessage) {
        self.init()
        caption = chatMessage.text
        guard let mediaAttachment = chatMessage.mediaAttachment else {
            return nil
        }
        mediaToUploadURL = mediaAttachment.url
        isGIF = mediaAttachment.type == .GIF
        isVideo = mediaAttachment.type == .Video        
    }
}
