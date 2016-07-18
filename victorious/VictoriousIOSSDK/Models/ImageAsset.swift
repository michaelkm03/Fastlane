//
//  ImageAsset.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import CoreGraphics

/// Conformers are models that store information about an image asset
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
public protocol ImageAssetModel {
    var mediaMetaData: MediaMetaData { get }
}

/// A thumbnail, profile picture, or other image asset
public struct ImageAsset: ImageAssetModel {
    public let mediaMetaData: MediaMetaData
    
    public init(mediaMetaData: MediaMetaData) {
        self.mediaMetaData = mediaMetaData
    }
    
    public init(url: NSURL) {
        let mediaMetaData = MediaMetaData(
            url: url,
            size: CGSize(width: 0, height: 0)
        )
        self.init(mediaMetaData: mediaMetaData)
    }
}

extension ImageAsset {
    public init?(json: JSON) {
        guard let mediaMetaData = MediaMetaData(json: json, customUrlKeys: ["imageUrl", "image_url", "imageURL"]) else {
            return nil
        }
        self.mediaMetaData = mediaMetaData
    }
}
