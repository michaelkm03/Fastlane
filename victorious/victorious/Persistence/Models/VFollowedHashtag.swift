//
//  VFollowedHashtag.swift
//  victorious
//
//  Created by Patrick Lynch on 12/26/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class VFollowedHashtag: NSManagedObject {
    @NSManaged var hashtag: VHashtag
    @NSManaged var user: VUser
    @NSManaged var displayOrder: NSNumber
}
