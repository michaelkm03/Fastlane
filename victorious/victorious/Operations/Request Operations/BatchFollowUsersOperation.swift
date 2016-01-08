//
//  BatchFollowUsersOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class BatchFollowUsersOperation: RequestOperation {
    let userIDs: [Int]

    init(userIDs: [Int]) {
        self.userIDs = userIDs
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
            }

            context.v_save()
        }
    }
}
