//
//  ImageSearchOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ImageSearchOperation: RemoteFetcherOperation, PaginatedRequestOperation {
	
    let request: ImageSearchRequest
	
	private let searchTerm: String
	
	required init( request: ImageSearchRequest ) {
		self.searchTerm = request.searchTerm
		self.request = request
	}
	
	convenience init( searchTerm: String ) {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)
        self.init( request: ImageSearchRequest(searchTerm: searchTerm, paginator: paginator) )
	}
	
	override func main() {
		requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: self.onError )
	}
	
	func onError( error: NSError, completion:()->() ) {
		self.results = []
		completion()
	}
	
	func onComplete( results: ImageSearchRequest.ResultType, completion:()->() ) {
		self.results = results.map { ImageSearchResultObject( $0 ) }
		completion()
    }
}

@objc class ImageSearchResultObject: NSObject, MediaSearchResult {
	
	let sourceResult: VictoriousIOSSDK.ImageSearchResult
	
	init( _ value: VictoriousIOSSDK.ImageSearchResult ) {
		self.sourceResult = value
	}
	
	// MARK: - MediaSearchResult
	
	var exportPreviewImage: UIImage?
	
	var exportMediaURL: NSURL?
	
	var sourceMediaURL: NSURL? {
		return sourceResult.imageURL
	}
	
	var thumbnailImageURL: NSURL? {
		return sourceResult.thumbnailURL
	}
	
	var aspectRatio: CGFloat {
		return 1.0
	}
	
	var assetSize: CGSize {
		return CGSize(width: 100, height: 100)
	}
	
	var remoteID: String? {
		return nil
	}
}
