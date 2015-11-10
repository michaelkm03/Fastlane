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
        guard let user = user,
            let recentSequences = recentSequences else {
                return nil
        }
        self.user = user
        self.recentSequences = recentSequences
    }
}
