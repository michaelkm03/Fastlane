//
//  VUser+AddRemoveFollower.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VUser {
    func addFollower(user: VUser) -> VFollowedUser {
        // Find or create the following relationship
        let uniqueElements = [ "subjectUser" : user, "objectUser" : self ]
        let followedUser: VFollowedUser = v_managedObjectContext.v_findOrCreateObject( uniqueElements )
        followedUser.objectUser = self
        followedUser.subjectUser = user

        // By setting display order to -1, the user will appear at the top
        // of each list of fetched results until a refresh of the followers list
        // comes back from the server with updated display order
        followedUser.displayOrder = -1

        return followedUser
    }

    func removeFollower(user: VUser) {
        let uniqueElements = [ "subjectUser" : user, "objectUser" : self ]
        if let followedUser: VFollowedUser = v_managedObjectContext.v_findObjects( uniqueElements ).first {
            v_managedObjectContext.deleteObject( followedUser )
        }
    }
}