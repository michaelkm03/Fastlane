//
//  GIFSearchResultObject.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class GIFSearchResultObject: NSObject, MediaSearchResult {
	
	let sourceResult: VictoriousIOSSDK.GIFSearchResult
	
    init( _ value: VictoriousIOSSDK.GIFSearchResult ) {
        self.sourceResult = value
	}
	
	// MARK: - MediaSearchResult
	
	var exportPreviewImage: UIImage?
	
	var exportMediaURL: URL?
	
	var sourceMediaURL: URL? {
		return URL(string: sourceResult.mp4URL)
	}
	
	var thumbnailImageURL: URL? {
		return URL(string: sourceResult.thumbnailStillURL)
	}
	
	var aspectRatio: CGFloat {
        guard sourceResult.height > 0 && sourceResult.width > 0 else {
            return 1.0
        }
		return CGFloat(sourceResult.width) / CGFloat(sourceResult.height)
	}
	
	var assetSize: CGSize {
		return CGSize(width: CGFloat(sourceResult.width), height: CGFloat(sourceResult.height))
	}
	
	var remoteID: String? {
		return sourceResult.remoteID
	}
    
    var isVIP: Bool {
        return false
    }
}
