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
    private(set) var suggestedUsers: [VSuggestedUser] = []
    
    init() {
        super.init(request: SuggestedUsersRequest())
    }
    
    override func onComplete(result: SuggestedUsersRequest.ResultType, completion: () -> ()) {
        suggestedUsers = result.flatMap() {
            let suggestedUser = VSuggestedUser()
            suggestedUser.populate(fromSourceModel: $0)
            return suggestedUser
        }
        completion()
    }
}
