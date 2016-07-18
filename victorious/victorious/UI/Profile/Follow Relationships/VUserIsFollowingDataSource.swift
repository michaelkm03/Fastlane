//
//  VUserIsFollowingDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc final class VUserIsFollowingDataSource: PaginatedDataSource, VUsersDataSource {
    
    let user: VUser
    
    init( user: VUser ) {
        self.user = user
    } 
    
    func users() -> NSOrderedSet {
        return self.visibleItems
    }
    
    func loadUsersWithPageType( pageType: VPageType, completion: (NSError? -> ())? = nil ) {
        let userID = self.user.remoteId.integerValue
        
        self.loadPage( pageType,
            createOperation: {
                return UsersFollowedByUserOperation(userID: userID)
            },
            completion:{ (results, error, cancelled) in
                completion?( error )
            }
        )
    }
    
    // MARK: - VUsersDataSource
    
    func noContentTitle() -> String {
        return self.user.isCurrentUser ? NSLocalizedString( "NotFollowingTitle", comment: "" ) : NSLocalizedString( "ProfileNotFollowingTitle", comment: "" )
    }
    
    func noContentMessage() -> String {
        return self.user.isCurrentUser ? NSLocalizedString( "NotFollowingMessage", comment: "" ) : NSLocalizedString( "ProfileNotFollowingMessage", comment: "" )
    }
    
    func noContentImage() -> UIImage {
        return UIImage(named: "noFollowersIcon" )!
    }
}
