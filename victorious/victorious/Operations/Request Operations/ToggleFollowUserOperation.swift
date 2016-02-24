//
//  ToggleFollowUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ToggleFollowUserOperation: FetcherOperation {
    
    let userID: Int
    let sourceScreenName: String
    
    init( userID: Int, sourceScreenName: String ) {
        self.userID = userID
        self.sourceScreenName = sourceScreenName
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            if currentUser.isFollowingUserID(self.userID) {
                UnfollowUserOperation(userID: self.userID, sourceScreenName: self.sourceScreenName).rechainAndQueueAfter(self)
            } else {
                FollowUsersOperation(userIDs: [self.userID], sourceScreenName: self.sourceScreenName).rechainAndQueueAfter(self)
            }
        }
    }
}
