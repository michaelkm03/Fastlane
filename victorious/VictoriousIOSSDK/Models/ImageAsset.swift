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
        guard let urlString = json["imageURL"].string,
            let url = NSURL(string: urlString),
            let width = json["width"].int,
            let type = json["type"].string,
            let height = json["height"].int else {
                return nil
        }
        
        self.url = url
        self.type = type
        self.size = CGSize(width: width, height: height)
        
        
        // MARK: Stageable
        self.resourceLocation = url.absoluteString
        // TODO: parse out other Stageable params
    }
}
