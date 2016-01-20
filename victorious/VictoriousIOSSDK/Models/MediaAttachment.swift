//
//  MediaAttachment.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum MediaAttachmentType: String {
    case Image      = "image"
    case Video      = "video"
    case GIF        = "gif"
    case Ballistic  = "voteType"
}

public struct MediaAttachment {
    public let type: MediaAttachmentType
    public let url: NSURL
    public let thumbnailURL: NSURL
    public let size: CGSize?
    public let isGIFStyle: Bool?
    public let shouldAutoplay: Bool?
    
    public init(
        url: NSURL,
        type: MediaAttachmentType,
        thumbnailURL: NSURL,
        size: CGSize?,
        isGIFStyle: Bool? = nil,
        shouldAutoplay: Bool? = nil) {
            self.type = type
            self.url = url
            self.size = size
            self.isGIFStyle = isGIFStyle
            self.thumbnailURL = thumbnailURL
            self.shouldAutoplay = shouldAutoplay
    }
}

extension MediaAttachment {
    
    public init?(json: JSON) {
        guard let type          = MediaAttachmentType(rawValue: json["media_type"].stringValue),
            let url             = NSURL(vsdk_string: json["media_url"].string),
            let thumbnailURL    = NSURL(vsdk_string: json["thumbnail_url"].string) else {
                return nil
        }
        self.url                = url
        self.thumbnailURL       = thumbnailURL
        self.type               = type
        
        self.isGIFStyle         = json["is_gif_style"].bool
        self.shouldAutoplay     = json["should_autoplay"].bool
        
        if let width = json["media_width"].float,
            let height = json["media_height"].float {
                self.size = CGSize(width: CGFloat(width), height: CGFloat(height))
        } else {
            self.size = nil
        }
    }
}
