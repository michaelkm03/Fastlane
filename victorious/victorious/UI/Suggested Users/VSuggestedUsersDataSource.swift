//
//  VSuggestedUsersDataSource.swift
//  victorious
//
//  Created by Tian Lan on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VSuggestedUsersDataSource {
    
    func loadSuggestedUsers(completion completion: ([VSuggestedUser]) -> Void) {
        let operation = SuggestedUsersOperation()
        operation.queue() { _ in
            let suggestedUsers = operation.results as? [VSuggestedUser] ?? []
            completion(suggestedUsers)
        }
    }
}
