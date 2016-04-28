//
//  ImageAsset.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

/// A thumbnail, profile picture, or other image asset
public struct ImageAsset {

    public let type: String
 
    public let mediaMetaData: MediaMetaData
}

extension ImageAsset {
    public init?(json: JSON) {
        guard let type = json["type"].string else {
                return nil
        }
        self.type = type
        
        // MARK: Stageable
        guard let mediaMetaData = MediaMetaData(json: json, customUrlKeys: ["imageUrl", "image_url", "imageURL"]) else {
            return nil
        }
        self.mediaMetaData = mediaMetaData
    }
}
