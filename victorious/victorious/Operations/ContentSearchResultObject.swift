//
//  ContentSearchResultObject.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class ContentSearchResultObject: NSObject, MediaSearchResult {
    
    let sourceResult: Content
    
    private var asset: ContentMediaAssetModel? {
        return self.sourceResult.assets.first
    }
    
    private var previewImageAsset: ImageAssetModel? {
        return self.sourceResult.previewImage(ofMinimumSize: .zero)
    }
    
    init( _ value: Content ) {
        self.sourceResult = value
    }
    
    // MARK: - MediaSearchResult
    
    var exportPreviewImage: UIImage?
    
    var exportMediaURL: NSURL?
    
    var sourceMediaURL: NSURL? {
        return asset?.url
    }
    
    var thumbnailImageURL: NSURL? {
        return previewImageAsset?.url
    }
    
    var aspectRatio: CGFloat {
        guard let size = previewImageAsset?.size else {
            return 1.0
        }
        return CGFloat(size.width) / CGFloat(size.height)
    }
    
    var assetSize: CGSize {
        guard let size = previewImageAsset?.size else {
            return .zero
        }
        return size
    }
    
    var remoteID: String? {
        return sourceResult.id
    }
}