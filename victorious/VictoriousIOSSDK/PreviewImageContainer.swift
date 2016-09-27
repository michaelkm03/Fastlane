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
    public func previewImage(ofMinimumSize minimumSize: CGSize) -> ImageAssetModel? {
        var qualifiedAsset: ImageAssetModel?
        
        let minimumWidth = minimumSize.width
        let minimumHeight = minimumSize.height
        
        for asset in previewImages ?? [] {
            let lastWidth = qualifiedAsset?.size.width ?? CGFloat.greatestFiniteMagnitude
            let lastHeight = qualifiedAsset?.size.height ?? CGFloat.greatestFiniteMagnitude
            let width = asset.size.width
            let height = asset.size.height

            if width >= minimumWidth && height >= minimumHeight && width <= lastWidth && height <= lastHeight {
                qualifiedAsset = asset
            }
        }
        
        return qualifiedAsset ?? largestPreviewImage
    }
    
    public func previewImage(ofMinimumWidth minimumWidth: CGFloat) -> ImageAssetModel? {
        var qualifiedAsset: ImageAssetModel?
        
        for asset in previewImages ?? [] {
            let lastWidth = qualifiedAsset?.size.width ?? CGFloat.greatestFiniteMagnitude
            let width = asset.size.width
            
            if width >= minimumWidth && width <= lastWidth {
                qualifiedAsset = asset
            }
        }
        
        return qualifiedAsset ?? largestPreviewImage
    }
    
    public var largestPreviewImage: ImageAssetModel? {
        var largestAsset: ImageAssetModel?
        
        for asset in previewImages ?? [] where asset.size.area > (largestAsset?.size.area)! {
            largestAsset = asset
        }
        
        return largestAsset
    }
}
