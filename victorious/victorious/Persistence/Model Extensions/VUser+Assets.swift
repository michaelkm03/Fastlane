//
//  VUser+Assets.swift
//  victorious
//
//  Created by Jarod Long on 4/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VUser {
    static var defaultSmallMinimumPictureSize: CGSize {
        return CGSize(width: 30.0, height: 30.0)
    }
    
    func pictureURL(ofMinimumSize minimumSize: CGSize) -> NSURL? {
        let assetFinder = VImageAssetFinder()
        
        if let assets = previewAssets where assets.count > 0 {
            if let smallestAsset = assetFinder.assetWithPreferredMinimumSize(minimumSize, fromAssets: assets) {
                return NSURL(string: smallestAsset.imageURL)
            }
            else if let fallbackAsset = assetFinder.largestAssetFromAssets(assets) {
                return NSURL(string: fallbackAsset.imageURL)
            }
        }
        
        return nil
    }
}
