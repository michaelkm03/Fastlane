//
//  FollowUserOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

class FollowUserOperation: RequestOperation {

    let request: FollowUserRequest
    private let userToFollowID: Int64
    private let screenName: String

    init(userToFollowID: Int64, screenName: String) {
        self.userToFollowID = userToFollowID
        self.screenName = screenName
        self.request = FollowUserRequest(userToFollowID: userToFollowID, screenName: screenName)
    }

    override func main() {
        
    }
}
