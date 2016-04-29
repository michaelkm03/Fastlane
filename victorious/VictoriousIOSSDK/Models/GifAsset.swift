//
//  GifAsset.swift
//  victorious
//
//  Created by Sebastian Nystorm on 14/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics

public struct GifAsset {
    public let thumbnailURL: String?

    public let mediaMetaData: MediaMetaData
}

extension GifAsset {
    public init?(json: JSON) {
        thumbnailURL = json["thumbnail_url"].string
        
        // MARK: Stageable
        guard let mediaMetaData = MediaMetaData(json: json, customUrlKeys: ["resourceLocation"]) else {
            return nil
        }
        self.mediaMetaData = mediaMetaData
    }
}
