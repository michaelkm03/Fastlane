//
//  FollowCount.swift
//  victorious
//
//  Created by Tian Lan on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct FollowCount {
    public let followingCount: Int64
    public let followersCount: Int64
}

extension FollowCount {
    public init?(json: JSON) {
        guard let followingCount = Int64(json["subscribed_to"].stringValue),
            let followersCount = Int64(json["followers"].stringValue) else {
                return nil
        }
        self.followingCount = followingCount
        self.followersCount = followersCount
    }
}
