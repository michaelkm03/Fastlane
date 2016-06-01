//
//  Stageable.swift
//  victorious
//
//  Created by Sebastian Nystorm on 18/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An enum that holds content being put on the stage.
public enum StageContent {
    case video(url: NSURL, seekAheadTime: NSTimeInterval?)
    case gif(url: NSURL)
    case image(url: NSURL)
    
    init?(json: JSON) {
        guard let contentTypeString = json["type"].string else {
            NSLog("Content type missing in content json -> \(json)")
            return nil
        }

        switch contentTypeString {
        case "video":
            guard let url = json["video", "video_assets", 0, "data"].URL else {
                return nil
            }
            self = .video(url: url, seekAheadTime: nil)
        case "gif":
            guard let url = json["gif", "remote_assets", 0, "external_source_url"].URL else {
                return nil
            }
            self = .gif(url: url)
        case "image":
            guard let url = json["image", "data"].URL else {
                return nil
            }
            self = .image(url: url)
        default:
            return nil
        }
    }

    /// URL pointing to the resource.
    public var url: NSURL {
        switch self {
        case .video(let url, _):
            return url
        case .gif(let url):
            return url
        case .image(let url):
            return url
        }
    }

    /// The amount in seconds to seek ahead in the video. Used to sync users watching the same content.
    public var seekAheadTime: NSTimeInterval? {
        switch self {
        case .video(_, let seekAheadTime):
            return seekAheadTime
        default:
            return nil
        }
    }
    
    /// Mutating function for updating the seek ahead time for videos.
    public mutating func updateSeekAheadTime(seekAheadTime: NSTimeInterval) {
        switch self {
        case .video(let url, _):
            self = .video(url: url, seekAheadTime: seekAheadTime)
        default: break
            // Only updated the seekAheadTime of a video.
        }
    }
}
