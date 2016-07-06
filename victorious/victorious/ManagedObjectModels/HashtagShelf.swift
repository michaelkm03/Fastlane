//
//  HashtagShelf.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData
import VictoriousIOSSDK

class HashtagShelf: Shelf {

    @NSManaged var hashtagTitle: String
    @NSManaged var amFollowing: NSNumber
    @NSManaged var postsCount: NSNumber

    override func populate(fromSourceShelf sourceShelf: StreamItemType) {
        guard let hashtagShelf = sourceShelf as? VictoriousIOSSDK.HashtagShelf else { return }
        
        super.populate(fromSourceShelf: hashtagShelf.shelf)
        
        self.hashtagTitle = hashtagShelf.hashtag.tag
        self.amFollowing = NSNumber(bool: false)
        self.postsCount = NSNumber(integer: hashtagShelf.postCount)
    }
}
