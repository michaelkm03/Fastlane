//
//  ContentType.swift
//  VictoriousIOSSDK
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public enum ContentType: String {
    case video = "video"
    case gif = "gif"
    case image = "image"
}

extension ContentType {
    public var displaysAsVideo: Bool {
        switch self {
        case .gif, .video:
            return true
        case .image:
            return false
        }
    }
    
    public var displaysAsImage: Bool {
        switch self {
        case .image:
            return true
        case .gif, .video:
            return false
        }
    }
}
