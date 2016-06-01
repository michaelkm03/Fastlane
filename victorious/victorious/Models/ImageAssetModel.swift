//
//  ImageAssetModel.swift
//  victorious
//
//  Created by Tian Lan on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers are models that store information about an image asset
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
protocol ImageAssetModel {
    var mediaMetaData: MediaMetaData { get }
    func toSDKImageAsset() -> ImageAsset
}

extension ImageAsset: ImageAssetModel {
    func toSDKImageAsset() -> ImageAsset {
        return self
    }
}

extension VImageAsset: ImageAssetModel {
    
    var mediaMetaData: MediaMetaData {
        var size: CGSize? = nil
        if let width = self.width?.floatValue,
            let height = self.height?.floatValue {
            size = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        // retrievedURL should be valid because it's an non optional property on the network model.
        // But due to Core Data limitations, we lose that information when we store the url as a String in core data
        // So we are doing the following nil coalescing and assertionFailure to catch the programmer error
        let retrievedURL = NSURL(string: imageURL)
        if retrievedURL == nil {
            assertionFailure("Retrieved imageURL should not be nil")
        }
        let validURL = retrievedURL ?? NSURL(string: "")!
        
        return MediaMetaData(url: validURL, size: size)
    }
    
    func toSDKImageAsset() -> ImageAsset {
        return ImageAsset(mediaMetaData: mediaMetaData)
    }
}
