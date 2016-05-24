//
//  ImageAssetModel.swift
//  victorious
//
//  Created by Tian Lan on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ImageAssetModel {
    var mediaMetaData: MediaMetaData { get }
}

extension ImageAsset: ImageAssetModel { }

extension VImageAsset: ImageAssetModel {
    
    var mediaMetaData: MediaMetaData {
        var size: CGSize? = nil
        if let width = self.width?.floatValue,
            let height = self.width?.floatValue{
            size = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        // retrivedURL should be valid because it's an non optional property on the network model.
        // But due to Core Data limitations, we lose that information when we store the url as a String in core data
        // So we are doing the following nil coalescing and assertionFailure to catch the programmer error
        let retrivedURL = NSURL(string: imageURL)
        if retrivedURL == nil {
            assertionFailure("Retrived imageURL should not be nil")
        }
        let validURL = retrivedURL ?? NSURL(string: "")!
        
        return MediaMetaData(url: validURL, size: size)
    }
}
