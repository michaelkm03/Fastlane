//
//  FollowHashtagToggleOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class FollowHashtagToggleOperation: FetcherOperation {
    
    let hashtag: String
    
    required init(hashtag: String) {
        self.hashtag = hashtag
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            if currentUser.isFollowingHashtagString(self.hashtag) {
                UnfollowHashtagOperation(hashtag: self.hashtag).rechainAfter(self).queue()
            } else {
                FollowHashtagOperation(hashtag: self.hashtag).rechainAfter(self).queue()
            }
        }
    }
}
