//
//  Stream.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct Stream: StreamItemType {
    
    public let streamID: String
    public let apiPath: String?
    public let name: String?
    public let title: String?
    public let postCount: Int?
    public let streamUrl: String?
    public let items: [StreamItemType]?
    public let marqueeItems: [StreamItemType]?
    public let streamContentType: StreamContentType?
    public let trackingIdentifier: String?
    public let isUserPostAllowed: Bool?
    
    // MARK: - StreamItemType
    
    public var streamItemID: String {
        return self.streamID
    }
    public let type: StreamContentType?
    public let subtype: StreamContentType?
    public let previewImagesObject: AnyObject?
    public let previewTextPostAsset: Asset?
    public let previewImageAssets: [ImageAsset]?
    public let releasedAt: NSDate?
}

extension Stream {
    public init?(json: JSON) {
        guard let streamID = json["id"].string else {
            return nil
        }
        self.streamID               = streamID
        
        releasedAt                  = NSDateFormatter.vsdk_defaultDateFormatter().dateFromString(json["posted_at"].stringValue)
        type                        = StreamContentType(rawValue: json["type"].stringValue)
        subtype                     = StreamContentType(rawValue: json["subtype"].stringValue)
        streamContentType           = StreamContentType(rawValue: json["stream_content_type"].stringValue)
        name                        = json["name"].string
        title                       = json["title"].string
        postCount                   = json["postCount"].int ?? json["count"].int
        streamUrl                   = json["streamUrl"].string
        trackingIdentifier          = json["apiPath"].string
        isUserPostAllowed           = json["ugc_post_allowed"].bool
        apiPath                     = json["streamUrl"].string ?? json["apiPath"].string
        
        items = (json["items"].array ?? json["content"].array ?? json["stream_items"].array)?.flatMap {
            switch $0["type"].stringValue {
            case "sequence":
                return Sequence(json: $0)
            case "shelf":
                switch $0["subtype"].stringValue {
                case "user":
                    return UserShelf(json: $0)
                case "playlist":
                    return ListShelf(json: $0)
                case "hashtag":
                    return HashtagShelf(json: $0)
                default:
                    return Shelf(json: $0)
                }
            default:
                return Stream(json: $0)
            }
        }
        
        marqueeItems = json["marquee"].array?.flatMap {
            switch $0["type"].stringValue {
            case "sequence":
                return Sequence(json: $0)
            default:
                return Stream(json: $0)
            }
        }
        
        // MARK: - StreamItemType
        
        previewTextPostAsset    = Asset(json: json["preview"])
        previewImageAssets      = json["preview"]["assets"].array?.flatMap { ImageAsset(json: $0) }
        
        let previewImage = json["preview_image"]
        previewImagesObject = (previewImage.array?.flatMap { $0.string } as? AnyObject) ?? previewImage.string as? AnyObject
    }
}
