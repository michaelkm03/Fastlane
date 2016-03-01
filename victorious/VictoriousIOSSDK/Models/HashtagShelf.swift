//
//  HashtagShelf.swift
//  victorious
//
//  Created by Tian Lan on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct HashtagShelf: StreamItemType {
    public let shelf: Shelf
    public let hashtag: Hashtag
    public let postCount: Int
    
    // MARK: - StreamItemType
    
    public var streamItemID: String {
        return shelf.streamID
    }
    public let type: StreamContentType?
    public let subtype: StreamContentType?
    public let previewImagesObject: AnyObject?
    public let previewTextPostAsset: Asset?
    public let previewImageAssets: [ImageAsset]?
    public let releasedAt: NSDate?
}

extension HashtagShelf {
    public init?(json: JSON) {
        guard let shelf = Shelf(json: json),
        let hashtag = Hashtag(json: json["hashtag"]),
        let postCount = shelf.postCount else {
            return nil
        }
        
        self.shelf = shelf
        self.hashtag = hashtag
        self.postCount = postCount
        
        // MARK: - StreamItemType
        
        self.type = shelf.type
        self.subtype = shelf.subtype
        self.previewImagesObject = shelf.previewImagesObject
        self.previewTextPostAsset = shelf.previewTextPostAsset
        self.previewImageAssets = shelf.previewImageAssets
        self.releasedAt = shelf.releasedAt
    }
}
