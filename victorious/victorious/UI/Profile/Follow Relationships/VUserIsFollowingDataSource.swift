//
//  VUserIsFollowingDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public extension VUserIsFollowingDataSource {
    
    func loadPage( pageType: VPageType, completion: ([VUser], NSError?) -> () ) {
        let userID = self.user.remoteId.longLongValue
        
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return UsersFollowedByUser(userID: userID)
            },
            completion:{ (operation, error) in
                completion( operation?.loadedUsers ?? [], error )
            }
        )
    }
}
