//
//  GIFSearchResult.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class VGIFSearchResult: NSObject {
    let gifURL: String
    let gifSize: Int64?
    let mp4URL: String
    let mp4Size: Int64?
    let frames: Int?
    let width: Int
    let height: Int
    let thumbnailURL: String?
    let thumbnailStillURL: String
    let remoteID: String
    
    init(networkingSearchResultModel searchResult: VictoriousIOSSDK.GIFSearchResult) {
        self.gifURL = searchResult.gifURL
        self.gifSize = searchResult.gifSize
        self.mp4URL = searchResult.mp4URL
        self.mp4Size = searchResult.mp4Size
        self.frames = searchResult.frames
        self.width = searchResult.width
        self.height = searchResult.height
        self.thumbnailURL = searchResult.thumbnailURL
        self.thumbnailStillURL = searchResult.thumbnailStillURL
        self.remoteID = searchResult.remoteID
    }
}
