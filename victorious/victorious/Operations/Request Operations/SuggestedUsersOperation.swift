//
//  SuggestedUsersOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SuggestedUsersOperation: RequestOperation<SuggestedUsersRequest> {
    private let persistenceStore: PersistentStoreType = MainPersistentStore()
    private(set) var suggestedUsers: [VUser] = []
    
    init() {
        super.init(request: SuggestedUsersRequest())
    }
    
    override func onComplete(result: SuggestedUsersRequest.ResultType, completion: () -> ()) {
        for user in result {
            let persistentUser = VUser()
            persistentUser.populate(fromSuggestedUserSourceModel: user)
            suggestedUsers.append(persistentUser)
        }
        completion()
    }
}
