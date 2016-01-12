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
    @NSManaged var displayOrder: NSNumber

    class func setupRelationshipBetween(objectUser objectUser: VUser, subjectUser: VUser, context: NSManagedObjectContext) -> VFollowedUser {
        // Find or create the following relationship
        let uniqueElements = [ "subjectUser" : subjectUser, "objectUser" : objectUser ]
        let followedUser: VFollowedUser = context.v_findOrCreateObject( uniqueElements )
        followedUser.objectUser = objectUser
        followedUser.subjectUser = subjectUser

        // By setting display order to -1, the user will appear at the top
        // of each list of fetched results until a refresh of the followers list
        // comes back from the server with updated display order
        followedUser.displayOrder = -1

        return followedUser
    }
}
