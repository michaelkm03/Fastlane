//
//  VFollowedHashtag.swift
//  victorious
//
//  Created by Patrick Lynch on 12/26/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc protocol VUserContext {
    var user: VUser { get }
}

class VFollowedHashtag: NSManagedObject {
    @NSManaged var hashtag: VHashtag
    @NSManaged var user: VUser
    @NSManaged var userId: NSNumber
    @NSManaged var displayOrder: NSNumber
}
