//
//  Content.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public class Content: Stageable {
    public let id: String
    public let status: String?
    public let title: String?
    public let tags: [String]?
    public let shareURL: NSURL?
    public let releasedAt: NSDate
    public let isUGC: Bool?

    // MARK: Stageable
    public let url: NSURL
    public let contentType: ContentType

    public init?(json: JSON) {
        guard let id = json["id"].string else {
            NSLog("ID misssing in content json -> \(json)")
            return nil
        }
        
        guard let contentTypeString = json["type"].string,
            let type = ContentType(rawValue: contentTypeString) else {
            NSLog("Content type misssing in content json -> \(json)")
            return nil
        }
        
        guard let url = type.contentURL(json) else {
            NSLog("Content URL misssing in content json -> \(json)")
            return nil
        }
        
        self.id = id
        self.contentType = type
        self.status = json["status"].string
        self.title = json["title"].string
        self.shareURL = json["share_url"].URL
        self.releasedAt = NSDate(timeIntervalSince1970: json["released_at"].doubleValue)
        self.isUGC = json["is_ugc"].bool
        self.tags = nil
        self.url = url
    }
}

private extension ContentType {
    func contentURL(json: JSON) -> NSURL? {
        var path: [JSONSubscriptType]!
        switch self {
        case .gif:
            path = ["gif", "remote_assets", 0, "external_source_url"]
        case .video:
            path = ["video", "video_assets", 0, "data"]
        case .image:
            path = ["image", "data"]
        }
        
        let url = json[path].URL
        return url
    }
}
