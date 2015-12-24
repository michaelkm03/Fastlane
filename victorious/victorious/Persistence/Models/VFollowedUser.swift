//
//  VFollowedUser.swift
//  victorious
//
//  Created by Patrick Lynch on 12/26/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class VFollowedUser: NSManagedObject {
    @NSManaged var subjectUser: VUser
    @NSManaged var objectUser: VUser
    @NSManaged var objectUserId: NSNumber
    @NSManaged var displayOrder: NSNumber
}


extension VFollowedUser: VUserContext {
    var user: VUser {
        return objectUser
    }
}