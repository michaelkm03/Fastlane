//
//  Content.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public class Content {
    public let id: String?
    public let status: String?
    public let text: String?
    public let tags: [String]?
    public let shareURL: NSURL?
    public let releasedAt: NSDate
    public let previewImages: [ImageAsset]?
    public let contentData: [ContentMediaAsset]
    public let type: ContentType
    public let isVIP: Bool
    public let author: User?

    /// Payload describing what will be put on the stage.
    public var stageContent: StageContent?

    public convenience init?(json: JSON) {
        // This supports parsing viewed content JSON as well as regular content JSON.
        if json["content"].isExists() {
            self.init(contentJSON: json["content"])
        } else {
            self.init(contentJSON: json)
        }
    }
    
    private init?(contentJSON json: JSON) {
        guard
            let id = json["id"].string,
            let typeString = json["type"].string,
            let type = ContentType(rawValue: typeString),
            let previewType = json["preview"]["type"].string,
            let sourceType = json[typeString]["type"].string
        else {
            NSLog("ID missing in content json -> \(json)")
            return nil
        }
        
        self.isVIP = json["is_vip"].bool ?? false
        self.stageContent = StageContent(json: json)
        self.id = id
        self.status = json["status"].string
        self.shareURL = json["share_url"].URL
        self.releasedAt = NSDate(timeIntervalSince1970: json["released_at"].doubleValue/1000) // Backend returns in milliseconds
        self.tags = nil
        self.type = type
        self.text = json["title"].string
        self.author = User(json: json["author"])
        
        self.previewImages = (json["preview"][previewType]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        
        if type == .image {
            if let asset = ContentMediaAsset(
                contentType: type,
                sourceType: sourceType,
                json: json[typeString]
                ) {
                self.contentData = [asset]
            } else {
                self.contentData = []
            }
        } else {
            self.contentData = (json[typeString][sourceType].array ?? []).flatMap {
                ContentMediaAsset(
                    contentType: type,
                    sourceType: sourceType,
                    json: $0
                )
            }
        }
    }
    
    public init?(chatMessageJSON json: JSON, serverTime: NSDate) {
        guard let user = User(json: json["user"]) else {
            return nil
        }
        
        author = user
        releasedAt = serverTime
        text = json["text"].string
        contentData = [ContentMediaAsset(forumJSON: json["media"])].flatMap { $0 }
        
        id = nil
        status = nil
        tags = nil
        shareURL = nil
        previewImages = nil
        type = .text
        isVIP = false
        
        // Either one of these types are required to be counted as a chat message.
        guard text != nil || contentData.count > 0 else {
            return nil
        }
    }
    
    public init(id: String? = nil, releasedAt: NSDate = NSDate(), type: ContentType = .text, text: String? = nil, assets: [ContentMediaAsset] = [], author: User? = nil) {
        self.id = id
        self.releasedAt = releasedAt
        self.type = type
        self.text = text
        self.author = author
        
        self.status = nil
        self.tags = nil
        self.shareURL = nil
        self.previewImages = nil
        self.contentData = assets
        self.isVIP = false
    }
}

extension Content: ForumEvent {
    public var serverTime: NSDate {
        return releasedAt
    }
}
