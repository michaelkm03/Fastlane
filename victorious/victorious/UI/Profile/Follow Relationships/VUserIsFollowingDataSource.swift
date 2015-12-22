//
//  VUserIsFollowingDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc class VUserIsFollowingDataSource: PaginatedDataSource, VUsersDataSource {
    
    let user: VUser
    
    init( user: VUser ) {
        self.user = user
    }
    
    func users() -> NSOrderedSet {
        return self.visibleItems
    }
    
    func loadUsersWithPageType( pageType: VPageType, completion: (NSError? -> ())? = nil ) {
        let userID = self.user.remoteId.longLongValue
        
        self.loadPage( pageType,
            createOperation: {
                return UsersFollowedByUser(userID: userID)
            },
            completion:{ (operation, error) in
                completion?( error )
            }
        )
    }
    
    // MARK: - VUsersDataSource
    
    func noContentTitle() -> String {
        return self.user.isCurrentUser() ? NSLocalizedString( "NotFollowingTitle", comment: "" ) : NSLocalizedString( "ProfileNotFollowingTitle", comment: "" )
    }
    
    func noContentMessage() -> String {
        return self.user.isCurrentUser() ? NSLocalizedString( "NotFollowingMessage", comment: "" ) : NSLocalizedString( "ProfileNotFollowingMessage", comment: "" )
    }
    
    func noContentImage() -> UIImage {
        return UIImage(named: "noFollowersIcon" )!
    }
}
