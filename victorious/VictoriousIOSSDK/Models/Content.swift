//
//  Content.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public class Content {
    public let id: String
    public let status: String?
    public let title: String?
    public let tags: [String]?
    public let shareURL: NSURL?
    public let releasedAt: NSDate
    public let isUGC: Bool?
    public let previewImages: [ImageAsset]?
    public let contentData: [ContentMediaAsset]?
    public let text: String?
    public let type: String
    public let isVIP: Bool?

    /// Payload describing what will be put on the stage.
    public var stageContent: StageContent?

    public init?(json: JSON, refreshStageEvent: RefreshStage? = nil) {
        guard let id = json["id"].string else {
            NSLog("ID missing in content json -> \(json)")
            return nil
        }
        
        guard let type = json["type"].string else {
            NSLog("Type missing in content json -> \(json)")
            return nil
        }
        
        guard let previewType = json["preview"]["type"].string else {
            NSLog("Preview type missing in content json -> \(json)")
            return nil
        }

        self.isVIP = json["is_vip"].bool
        self.stageContent = StageContent(json: json)
        self.id = id
        self.status = json["status"].string
        self.title = json["title"].string
        self.shareURL = json["share_url"].URL
        self.releasedAt = NSDate(timeIntervalSince1970: json["released_at"].doubleValue/1000) /// <backend returns in milliseconds
        self.isUGC = json["is_ugc"].bool
        self.tags = nil
        self.text = json["text"]["data"].string
        self.type = type
        
        self.previewImages = (json["preview"][previewType]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        
        if type == "image" {
            self.contentData = [ContentMediaAsset(
                contentType: type,
                sourceType: "",
                json: json[type]
            )].flatMap { $0 }
        } else {
            let sourceType = json[type]["type"].string ?? ""
            
            self.contentData = (json[type][sourceType].array ?? []).flatMap {
                ContentMediaAsset(
                    contentType: type,
                    sourceType: sourceType,
                    json: $0
                )
            }
        }
    }
    
    public init(id: String, title: String, releasedAt: NSDate, type: String) {
        self.id = id
        self.title = title
        self.releasedAt = releasedAt
        
        self.status = nil
        self.tags = nil
        self.shareURL = nil
        self.isUGC = nil
        self.previewImages = nil
        self.contentData = nil
        self.text = nil
        self.type = type
        self.isVIP = nil
    }
}
