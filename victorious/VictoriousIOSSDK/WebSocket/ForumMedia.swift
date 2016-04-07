//
//  ForumMedia.swift
//  victorious
//
//  Created by Patrick Lynch on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

public struct ForumMedia {
    public let url: NSURL
    public let thumbnailUrl: NSURL
    public let width: Int
    public let height: Int
    public let loop: Bool
    public let audioEnabled: Bool
    
    public var aspectRatio: CGFloat { return CGFloat(width) / CGFloat(height) }
}
