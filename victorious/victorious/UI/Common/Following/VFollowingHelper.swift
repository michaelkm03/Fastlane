//
//  VFollowingHelper.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

extension VFollowingHelper {
    func followUser(userToFollowID userToFollowID: NSNumber,
        currentUserID: NSNumber,
        screenName: String,
        successBlock: VSuccessBlock,
        failBlock: VFailBlock) {

        let operation = FollowUserOperation(userToFollowID: userToFollowID.integerValue,
            currentUserID: currentUserID.integerValue,
            screenName: screenName)

        operation.queue() { error in
            if let error = error {
                failBlock(operation, error)
            } else {
                successBlock(operation, nil, [])
            }
        }
    }
}
