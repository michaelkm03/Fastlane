//
//  GIFSearchResult.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc protocol MediaSearchResult: class {
	var exportPreviewImage: UIImage? { get set }
	var exportMediaURL: NSURL? { get set }
	var sourceMediaURL: NSURL? { get }
	var thumbnailImageURL: NSURL? { get }
	var aspectRatio: CGFloat { get }
	var assetSize: CGSize { get }
	var remoteID: String? { get }
}

@objc class GIFSearchResultObject: NSObject, MediaSearchResult {
	
	let sourceResult: VictoriousIOSSDK.GIFSearchResult
	
    init( _ value: VictoriousIOSSDK.GIFSearchResult ) {
        self.sourceResult = value
	}
	
	// MARK: - MediaSearchResult
	
	var exportPreviewImage: UIImage?
	
	var exportMediaURL: NSURL?
	
	var sourceMediaURL: NSURL? {
		return NSURL(string: sourceResult.mp4URL)
	}
	
	var thumbnailImageURL: NSURL? {
		return NSURL(string: sourceResult.thumbnailStillURL)
	}
	
	var aspectRatio: CGFloat {
		return CGFloat(sourceResult.width) / CGFloat(sourceResult.height)
	}
	
	var assetSize: CGSize {
		return CGSize(width: CGFloat(sourceResult.width), height: CGFloat(sourceResult.height))
	}
	
	var remoteID: String? {
		return sourceResult.remoteID
	}
}
