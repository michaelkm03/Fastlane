//
//  VSuggestedUsersDataSource.swift
//  victorious
//
//  Created by Tian Lan on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VSuggestedUsersDataSource {
    func refresh(completion: () -> Void) {
        let operation = SuggestedUsersOperation()
        operation.queue() { error in
            if let e = error {
                
            } else {
                
            }
        }
    }
}
