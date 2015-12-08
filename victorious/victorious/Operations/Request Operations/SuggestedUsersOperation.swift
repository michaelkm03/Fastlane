//
//  SuggestedUsersOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SuggestedUsersOperation: RequestOperation {
    
    let request = SuggestedUsersRequest()
    
    private(set) var suggestedUsers: [VSuggestedUser] = []
    
    override func main() {
        executeRequest( self.request, onComplete: self.onComplete )
    }
    
    func onComplete( users: [SuggestedUser], completion:()->() ) {
        suggestedUsers = users.flatMap() {
            let suggestedUser = VSuggestedUser()
            suggestedUser.populate(fromSourceModel: $0)
            return suggestedUser
        }
        completion()
    }
}
