//
//  MediaAttachment.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

public enum MediaAttachmentType: String {
    case Image      = "image"
    case Video      = "video"
    case GIF        = "gif"
    case Ballistic  = "voteType"
}

public enum MimeType: String {
    case HLSStream  = "application/x-mpegURL"
    case MP4        = "video/mp4"
}

public struct MediaAttachment {
    
    public struct Format {
        public let mimeType: MimeType
        public let url: NSURL
    }
    
    public let type: MediaAttachmentType
    public let url: NSURL
    public let thumbnailURL: NSURL?
    public let size: CGSize?
    public let isGIFStyle: Bool?
    public let shouldAutoplay: Bool?
    public let formats: [MediaAttachment.Format]?
    
    public init(
        url: NSURL,
        type: MediaAttachmentType,
        thumbnailURL: NSURL?,
        size: CGSize?,
        isGIFStyle: Bool? = nil,
        shouldAutoplay: Bool? = nil,
        formats: [MediaAttachment.Format]? = nil) {
            self.type = type
            self.url = url
            self.size = size
            self.isGIFStyle = isGIFStyle
            self.thumbnailURL = thumbnailURL
            self.shouldAutoplay = shouldAutoplay
            self.formats = formats
    }
    
    public var aspectRatio: CGFloat {
        guard let size = size else {
            return  0.0
        }
        return CGFloat(size.width) / CGFloat(size.height)
    }
}

extension MediaAttachment {
    
    public init?(json: JSON) {
        guard let type = MediaAttachmentType(rawValue: json["media_type"].stringValue),
            let url = NSURL(vsdk_string: json["media_url"].string),
            let thumbnailURL = NSURL(vsdk_string: json["thumbnail_url"].string) else {
                return nil
        }
        
        self.url                = url
        self.thumbnailURL       = thumbnailURL
        self.shouldAutoplay     = json["should_autoplay"].bool
        
        if let shouldAutoplay = self.shouldAutoplay , shouldAutoplay == true {
            self.type = .GIF
        } else {
            self.type = type
        }
        
        self.isGIFStyle = json["is_gif_style"].bool
        
        
        if let width = json["media_width"].float,
            let height = json["media_height"].float {
                self.size = CGSize(width: CGFloat(width), height: CGFloat(height))
        } else {
            self.size = nil
        }
        
        if let media = json["media"].array {
            var mediaFormats: [MediaAttachment.Format] = []
            for mediaFormatJSON in media {
                if let format = MediaAttachment.Format.init(json: mediaFormatJSON) {
                    mediaFormats.append(format)
                }
            }
            self.formats = mediaFormats
        } else {
            self.formats = nil
        }
    }
    
    public func mp4URLForMediaAttachment() -> NSURL? {
        var url: NSURL? = nil
        
        // We MUST use the MP4 asset for gifs
        if let formats = formats , type == .GIF {
            for format in formats {
                if format.mimeType == .MP4 {
                    url = format.url
                }
            }
        }
        return url
    }
}

extension MediaAttachment.Format {
    
    public init(url: NSURL, mimeType: MimeType) {
        self.url = url
        self.mimeType = mimeType
    }
    
    public init?(json: JSON) {
        guard let dataString = json["data"].string,
            let mediaURL = NSURL(string: dataString),
            let mimeTypeString = json["mime_type"].string,
            let mimeType = MimeType(rawValue: mimeTypeString) else {
                return nil
        }
        self.url = mediaURL
        self.mimeType = mimeType
    }
}
