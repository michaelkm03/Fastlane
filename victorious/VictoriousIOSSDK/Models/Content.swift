//
//  Content.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentDataAsset {
    public let width: Double?
    public let height: Double?
    public let duration: Double?
    public let data: String?
}

extension ContentDataAsset {
    public init?(json: JSON) {
        data            = json["data"].string
        duration        = json["duration"].double
        width           = json["width"].double
        height          = json["height"].double
    }
}

public class Content {
    public let id: String
    public let status: String?
    public let title: String?
    public let tags: [String]?
    public let shareURL: NSURL?
    public let releasedAt: NSDate
    public let isUGC: Bool?
    public let previewImages: [ImageAsset]?
    public let contentData: [ContentDataAsset]?

    /// Payload describing what will be put on the stage.
    public var stageContent: StageContent?

    public init?(json: JSON, refreshStageEvent: RefreshStage? = nil) {
        guard let id = json["id"].string,
            let type = json["type"].string,
            let previewType = json["preview"]["type"].string,
            let contentType = json[type]["type"].string else {
            NSLog("ID misssing in content json -> \(json)")
            return nil
        }

        self.stageContent = StageContent(json: json)
        self.id = id
        self.status = json["status"].string
        self.title = json["title"].string
        self.shareURL = json["share_url"].URL
        self.releasedAt = NSDate(timeIntervalSince1970: json["released_at"].doubleValue)
        self.isUGC = json["is_ugc"].bool
        self.tags = nil
        
        self.previewImages = (json["preview"][previewType]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        self.contentData = (json[type][contentType].array ?? []).flatMap { ContentDataAsset(json: $0) }
    }
}
