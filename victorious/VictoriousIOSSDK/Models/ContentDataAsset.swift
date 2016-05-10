//
//  ContentDataAsset.swift
//  victorious
//
//  Created by Vincent Ho on 5/10/16.
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
                } else if contentType == "gif" {
                    self = .gif(url: url!, source: source)
                } else {
                    return nil
                }
            } else {
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