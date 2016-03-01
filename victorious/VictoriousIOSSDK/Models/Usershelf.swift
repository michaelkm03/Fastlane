//
//  Usershelf.swift
//  victorious
//
//  Created by Tian Lan on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct UserShelf: StreamItemType {
    public let shelf: Shelf
    public let followersCount: Int
    public let user: User
    
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

extension UserShelf {
    public init?(json: JSON) {
        guard let shelf = Shelf(json: json),
            let followersCount = json["followersCount"].int,
            let user = User(json: json["user"]) else {
                return nil
        }
        self.shelf = shelf
        self.followersCount = followersCount
        self.user = user
        
        // MARK: - StreamItemType

        self.type = shelf.type
        self.subtype = shelf.subtype
        self.previewImagesObject = shelf.previewImagesObject
        self.previewTextPostAsset = shelf.previewTextPostAsset
        self.previewImageAssets = shelf.previewImageAssets
        self.releasedAt = shelf.releasedAt
    }
}
