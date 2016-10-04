//
//  MediaAttachment+Forum.swift
//  victorious
//
//  Created by Patrick Lynch on 4/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreGraphics

public extension MediaAttachment {
    
    public init?(fromForumJSON json: JSON) {
        guard let type = MediaAttachmentType.value(fromForumValue: json["type"].stringValue),
            let url = NSURL(vsdk_string: json["url"].string),
            let height = json["height"].int,
            let width = json["width"].int else {
                return nil
        }
        self.type = type
        self.url = url
        self.size = CGSize(width: CGFloat(width), height: CGFloat(height))
        self.thumbnailURL = NSURL(vsdk_string: json["thumbnail_url"].string)

        // Not needed for forum.
        self.isGIFStyle = nil
        self.shouldAutoplay = nil
        self.formats = nil
    }
}

extension MediaAttachment: DictionaryConvertible {
    
    public var rootKey: String {
        return "media"
    }

    public var rootTypeKey: String? {
        return nil
    }

    public var rootTypeValue: String? {
        return nil
    }

    public func toDictionary() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        if let width = size?.width {
            dictionary["width"] = width as AnyObject?
        }
        if let height = size?.height {
            dictionary["height"] = height as AnyObject?
        }
        dictionary["type"] = type.forumRawValue as AnyObject?
        dictionary["thubmnail_url"] = thumbnailURL?.absoluteString as AnyObject?
        dictionary["url"] = url.absoluteString as AnyObject?
        return dictionary
    }
}

/// Defines an alternate set of raw values to adapt to `MediaAttachmentType`.
private enum ForumMediaAttachmentType: String {
    case Image      = "IMAGE"
    case Video      = "VIDEO"
    case GIF        = "GIF"
    case Ballistic  = "VOTE_TYPE"
}

private extension MediaAttachmentType {
    
    static func value(fromForumValue value: MediaAttachmentType.RawValue) -> MediaAttachmentType? {
        guard let forumValue = ForumMediaAttachmentType(rawValue: value) else {
            return nil
        }
        switch forumValue {
        case .Image:
            return .Image
        case .Video:
            return .Video
        case .GIF:
            return .GIF
        case .Ballistic:
            return .Ballistic
        }
    }
    
    var forumRawValue: ForumMediaAttachmentType.RawValue {
        switch self {
        case .Image:
            return ForumMediaAttachmentType.Image.rawValue
        case .Video:
            return ForumMediaAttachmentType.Video.rawValue
        case .GIF:
            return ForumMediaAttachmentType.GIF.rawValue
        case .Ballistic:
            return ForumMediaAttachmentType.Ballistic.rawValue
        }
    }
}
