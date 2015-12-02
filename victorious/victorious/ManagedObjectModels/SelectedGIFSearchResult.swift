//
//  GIFSearchResult.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class SelectedGIFSearchResult: NSObject {
    let width: Int
    let height: Int
    let remoteID: String
    let previewImage: UIImage
    let mediaURL: NSURL
    
    init(networkingSearchResultModel searchResult: GIFSearchResult, previewImage: UIImage, mediaURL: NSURL) {
        self.width = searchResult.width
        self.height = searchResult.height
        self.remoteID = searchResult.remoteID
        self.previewImage = previewImage
        self.mediaURL = mediaURL
    }
}
