//
//  VUser+FollowedHashtags.swift
//  victorious
//
//  Created by Patrick Lynch on 12/26/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VUser {
    
    func isFollowingHashtagString( hashtagString: String ) -> Bool {
        let array = (self.followedHashtags.array as? [VFollowedHashtag] ?? [])
        return array.contains { $0.hashtag.tag == hashtagString }
    }
}
