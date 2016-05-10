//
//  Content.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public enum ContentDataAsset {
    case video(url: NSURL, source: String?)
    case gif(url: NSURL, source: String?)
    case image(url: NSURL)
    
    init?(contentType: String, sourceType: String, json: JSON) {
        
        switch contentType {
        case "image":
            guard let url = json["data"].URL else {
                return nil
            }
            self = .image(url: url)
        case "video", "gif":
            var url: NSURL?
            
            switch sourceType {
            case "video_assets":
                url = json["data"].URL
            case "remote_assets":
                url = json["remote_content_url"].URL
            default:
                return nil
            }
            
            let source = json["source"].string
            
            if url != nil {
                if contentType == "video" {
                    self = .video(url: url!, source: source)
                }
                else if contentType == "gif" {
                    self = .gif(url: url!, source: source)
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        default:
            return nil
        }
    }
    
    /// URL pointing to the resource.
    public var url: NSURL {
        switch self {
        case .video(let url, _):
            return url
        case .gif(let url, _):
            return url
        case .image(let url):
            return url
        }
    }
    
    /// String describing the source. May return "youtube", "giphy", or nil.
    public var source: String? {
        switch self {
        case .video(_, let source):
            return source
        case .gif(_, let source):
            return source
        default:
            return nil
        }
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
            let sourceType = json[type]["type"].string else {
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
        self.contentData = (json[type][sourceType].array ?? []).flatMap {
            ContentDataAsset(
                contentType: type,
                sourceType: sourceType,
                json: $0
            )
        }
    }
}
