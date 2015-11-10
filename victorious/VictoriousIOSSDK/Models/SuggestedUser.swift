//
//  SuggestedUser.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

public struct SuggestedUser {
    public let user: User
    public let recentSequences: [Sequence]
    
    public init?(user: User?, recentSequences: [Sequence]?) {
        if let user = user,
            let recentSequences = recentSequences {
                self.user = user
                self.recentSequences = recentSequences
        } else {
            return nil
        }
    }
}
