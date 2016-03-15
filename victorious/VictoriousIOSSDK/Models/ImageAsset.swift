//
//  ImageAsset.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

/// A thumbnail, profile picture, or other image asset
public struct ImageAsset: Stageable {

    public let url: NSURL
    public let size: CGSize
    public let type: String
 
    // MARK: Stageable
    public var duration: Double?
    public var endTime: Double?
    public var resourceLocation: String?
}

extension ImageAsset {
    public init?(json: JSON) {
        guard let urlString = json["image_url"].string,
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
        resourceLocation = url.absoluteString
        endTime = json["end_time"].double
        duration = json["duration"].double
    }
}
