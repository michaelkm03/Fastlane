//
//  BatchFollowUsersOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

class BatchFollowUsersOperation: RequestOperation {
    let userIDs: [Int]
    let request: BatchFollowUsersRequest

    init(userIDs: [Int]) {
        self.userIDs = userIDs
        self.request = BatchFollowUsersRequest(usersToFollow: self.userIDs)
        super.init()
    }

    override func main() {
        persistentStore.backgroundContext.v_performBlockAndWait() { context in
            guard let subjectUser: VUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }

            for userID in self.userIDs {
                guard let objectUser: VUser = context.v_findObjects(["remoteId" : userID]).first else {
                    return
                }

                objectUser.numberOfFollowers = objectUser.numberOfFollowers + 1
                subjectUser.numberOfFollowing = subjectUser.numberOfFollowing + 1
                objectUser.isFollowedByMainUser = true
                VFollowedUser.setupRelationshipBetween(objectUser: objectUser, subjectUser: subjectUser, context: context)
            }

            context.v_save()
            self.requestExecutor.executeRequest( self.request, onComplete: nil, onError: nil )
        }
    }
}
