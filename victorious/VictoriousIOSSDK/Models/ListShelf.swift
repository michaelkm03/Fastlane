//
//  ListShelf.swift
//  victorious
//
//  Created by Tian Lan on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ListShelf: StreamItemType {
    public let shelf: Shelf
    public let caption: String
    
    // MARK: - StreamItemType
    
    public var streamItemID: String {
        return shelf.streamID
    }
    public let type: StreamContentType?
    public let subtype: StreamContentType?
    public let previewImagesObject: AnyObject?
    public let previewAsset: Asset?
    public let previewImageAssets: [ImageAsset]?
    public let releasedAt: NSDate?
}

extension ListShelf {
    public init?(json: JSON) {
        guard let shelf = Shelf(json: json),
            let caption = json["caption"].string else {
                return nil
        }
        self.shelf = shelf
        self.caption = caption
        
        // MARK: - StreamItemType
        
        self.type = shelf.type
        self.subtype = shelf.subtype
        self.previewImagesObject = shelf.previewImagesObject
        self.previewAsset = shelf.previewAsset
        self.previewImageAssets = shelf.previewImageAssets
        self.releasedAt = shelf.releasedAt
    }
}
