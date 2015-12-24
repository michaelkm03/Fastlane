//
//  FollowUserOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

class FollowUserOperation: RequestOperation {

    var onComplete: (() -> Void)?
    private let request:        FollowUserRequest
    private let userToFollowID: Int64
    private let screenName:     String

    init(userToFollowID: Int64, screenName: String, persistentStore: PersistentStoreType = MainPersistentStore()) {
        self.userToFollowID = userToFollowID
        self.screenName     = screenName
        self.request        = FollowUserRequest(userToFollowID: userToFollowID, screenName: screenName)
        super.init(persistentStore: persistentStore)
    }

    override func main() {
        persistentStore.backgroundContext.v_performBlock { context in
            let userToFollowIDNumber = NSNumber(longLong: self.userToFollowID)
            let user: VUser          = context.v_findOrCreateObject(["remoteId" : userToFollowIDNumber])
            user.numberOfFollowers   = self.initializeOrIncrease(number: user.numberOfFollowers)
            context.v_save()
            self.onComplete?()
        }
    }

    private func initializeOrIncrease(number number: NSNumber?) -> NSNumber {
        if let number = number {
            return NSNumber(int: number.integerValue + 1)
        } else {
            return NSNumber(int: 1)
        }
    }
}
