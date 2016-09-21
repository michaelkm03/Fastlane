//
//  ContentType.swift
//  VictoriousIOSSDK
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public enum ContentType: String {
    case text = "text"
    case link = "link"
    case video = "video"
    case gif = "gif"
    case image = "image"
    case sticker = "sticker"
    
    public var displaysAsVideo: Bool {
        switch self {
            case .gif, .video, .sticker: return true
            case .text, .link, .image: return false
        }
    }
    
    public var displaysAsImage: Bool {
        switch self {
            case .image, .link, .sticker: return true
            case .text, .gif, .video: return false
        }
    }
    
    public var previewsAsImage: Bool {
        switch self {
            case .image, .video, .sticker: return true
            case .link, .text, .gif: return false
        }
    }
    
    public var previewsAsVideo: Bool {
        switch self {
            case .gif: return true
            case .image, .link, .text, .video, .sticker: return false
        }
    }
    
    public var hasMedia: Bool {
        switch self {
            case .text: return false
            case .image, .link, .gif, .video, .sticker: return true
        }
    }
}
