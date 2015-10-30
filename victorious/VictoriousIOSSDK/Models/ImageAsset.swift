//
//  ImageAsset.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import SwiftyJSON

/// A thumbnail, profile picture, or other image asset
public struct ImageAsset {
    public let url: NSURL
    public let size: CGSize
    
    public init(url: NSURL, size: CGSize) {
        self.url = url
        self.size = size
    }
}

extension ImageAsset {
    public init?(json: JSON) {
        if let urlString = json["imageURL"].string,
           let url = NSURL(string: urlString),
           let width = json["width"].number,
           let height = json["height"].number {
            self.init(url: url, size: CGSizeMake(CGFloat(width.doubleValue), CGFloat(height.doubleValue)))
        } else {
            return nil
        }
    }
}
