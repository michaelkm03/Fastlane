//
//  ImageAsset.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import CoreGraphics

/// A thumbnail, profile picture, or other image asset
public struct ImageAsset: Stageable {

    public let size: CGSize
    public let type: String
 
    // MARK: Stageable
    public let duration: Double?
    public let url: NSURL
}

extension ImageAsset {
    public init?(json: JSON) {
        guard let urlString = json["imageURL"].string ?? json["image_url"].string,
            let url = NSURL(string: urlString),
            let type = json["type"].string,
            let width = json["width"].int,
            let height = json["height"].int else {
                return nil
        }
        
        self.url = url
        self.type = type
        self.size = CGSize(width: width, height: height)
        
        // MARK: Stageable
        if let duration = json["duration"].double {
            self.duration = duration
        } else {
            self.duration = nil
        }
    }
}
