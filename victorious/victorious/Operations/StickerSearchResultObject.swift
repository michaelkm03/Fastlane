//
//  StickerSearchResultObject.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class StickerSearchResultObject: NSObject, MediaSearchResult {
    let sourceResult: StickerSearchResult
    
    init( _ value: StickerSearchResult ) {
        self.sourceResult = value
    }
    
    // MARK: - MediaSearchResult
    
    var exportPreviewImage: UIImage?
    
    var exportMediaURL: URL?
    
    var sourceMediaURL: URL? {
        return URL(string: sourceResult.url)
    }
    
    var thumbnailImageURL: URL? {
        return URL(string: sourceResult.url)
    }
    
    var aspectRatio: CGFloat {
        guard sourceResult.height > 0 && sourceResult.width > 0 else {
            return 1.0
        }
        return CGFloat(sourceResult.width) / CGFloat(sourceResult.height)
    }
    
    var assetSize: CGSize {
        return CGSize(width: sourceResult.width, height: sourceResult.height)
    }
    
    var remoteID: String? {
        return sourceResult.remoteID
    }
    
    var isVIP: Bool {
        return sourceResult.isVIP
    }
}
