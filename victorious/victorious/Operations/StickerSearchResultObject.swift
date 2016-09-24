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
    
    var exportMediaURL: NSURL?
    
    var sourceMediaURL: NSURL? {
        return NSURL(string: sourceResult.url)
    }
    
    var thumbnailImageURL: NSURL? {
        return NSURL(string: sourceResult.url)
    }
    
    var aspectRatio: CGFloat {
        return 1
    }
    
    var assetSize: CGSize {
        return .zero
    }
    
    var remoteID: String? {
        return sourceResult.remoteID
    }
    
    var isVIP: Bool {
        return sourceResult.isVIP
    }
}