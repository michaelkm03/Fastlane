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
    case video = "video"
    case gif = "gif"
    case image = "image"
    
    public var displaysAsVideo: Bool {
        switch self {
            case .gif, .video: return true
            case .text, .image: return false
        }
    }
    
    public var displaysAsImage: Bool {
        switch self {
            case .image: return true
            case .text, .gif, .video: return false
        }
    }
    
    public var hasMedia: Bool {
        switch self {
            case .text: return false
            case .image, .gif, .video: return true
        }
    }
}
