//
//  MediaAttachmentType.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

enum MediaAttachmentType {
    case Image, Video, Ballistic, GIF, NoMedia
    var description : String {
        switch (self) {
        case .Image:
            return "Image"
        case .Video:
            return "Video"
        case .Ballistic:
            return "Ballistic"
        case .GIF:
            return "GIF"
        default:
            return "NoMedia"
        }
    }
    
    static func attachmentType(comment: VComment) -> MediaAttachmentType {
        let commentMediaType = comment.commentMediaType()
        switch (commentMediaType) {
        case .Image:
            return .Image
        case .Video:
            return .Video
        case .GIF:
            return .GIF
        case .Ballistic:
            return .Ballistic
        default:
            return .NoMedia
        }
    }
    
    static func attachmentType(message: VMessage) -> MediaAttachmentType {
        let messageMediaType = message.messageMediaType()
        switch (messageMediaType) {
        case .Image:
            return .Image
        case .GIF:
            return .GIF
        case .Video:
            return .Video
        default:
            return .NoMedia
        }
    }
}