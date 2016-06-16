//
//  PreviewImageContainer.swift
//  VictoriousIOSSDK
//
//  Created by Jarod Long on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics
import Foundation

/// A protocol that can be conformed to for some convenient functionality for models with preview images.
public protocol PreviewImageContainer {
    var previewImages: [ImageAssetModel] { get }
}

extension PreviewImageContainer {
    public func previewImageURL(ofMinimumSize minimumSize: CGSize) -> NSURL? {
        for asset in previewImages ?? [] where asset.mediaMetaData.size?.contains(minimumSize) == true {
            return asset.mediaMetaData.url
        }
        
        return largestPreviewImageURL
    }
    
    public func previewImageURL(ofMinimumWidth minimumWidth: CGFloat) -> NSURL? {
        for asset in previewImages ?? [] where asset.mediaMetaData.size?.width >= minimumWidth {
            return asset.mediaMetaData.url
        }
        
        return largestPreviewImageURL
    }
    
    public var largestPreviewImageURL: NSURL? {
        var largestAsset: ImageAssetModel?
        
        for asset in previewImages ?? [] where asset.mediaMetaData.size?.area > largestAsset?.mediaMetaData.size?.area {
            largestAsset = asset
        }
        
        return largestAsset?.mediaMetaData.url
    }
}
