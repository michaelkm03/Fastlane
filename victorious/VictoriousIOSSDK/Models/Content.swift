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
    public let type: String?

    /// Payload describing what will be put on the stage.
    public var stageContent: StageContent?

    public init?(json: JSON, refreshStageEvent: RefreshStage? = nil) {
        guard let id = json["id"].string,
            let type = json["type"].string,
            let previewType = json["preview"]["type"].string,
            let sourceType = json[type]["type"].string else {
            NSLog("ID misssing in content json -> \(json)")
            return nil
        }

        self.stageContent = StageContent(json: json)
        self.id = id
        self.status = json["status"].string
        self.title = json["title"].string
        self.shareURL = json["share_url"].URL
        self.releasedAt = NSDate(timeIntervalSince1970: json["released_at"].doubleValue/1000) /// <backend returns in milliseconds
        self.isUGC = json["is_ugc"].bool
        self.tags = nil
        self.type = type
        
        self.previewImages = (json["preview"][previewType]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        if type == "image" {
            if let asset = ContentMediaAsset(
                contentType: type,
                sourceType: sourceType,
                json: json[type]
                ) {
                self.contentData = [asset]
            } else {
                self.contentData = []
            }
        } else {
            self.contentData = (json[type][sourceType].array ?? []).flatMap {
                ContentMediaAsset(
                    contentType: type,
                    sourceType: sourceType,
                    json: $0
                )
            }
        }
    }
    
    public init(id: String, title: String, releasedAt: NSDate) {
        self.id = id
        self.title = title
        self.releasedAt = releasedAt
        
        self.status = nil
        self.tags = nil
        self.shareURL = nil
        self.isUGC = nil
        self.previewImages = nil
        self.contentData = nil
        self.type = nil
    }
}
