//
//  VUser+Following.swift
//  victorious
//
//  Created by Patrick Lynch on 1/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VUser {
   
    func isFollowingHashtagString(hashtagString: String) -> Bool {
        let predicate = NSPredicate(format: "user.remoteId == %i && hashtag.tag == %@", self.remoteId.integerValue, hashtagString)
        return self.followedHashtags?.filteredOrderedSetUsingPredicate(predicate).count > 0
    }
    
    func isFollowingUserID(userID: Int) -> Bool {
        let predicate = NSPredicate(format: "subjectUser.remoteId == %i && objectUser.remoteId == %i", self.remoteId.integerValue, userID)
        return self.following?.filteredOrderedSetUsingPredicate(predicate).count > 0
    }
}
