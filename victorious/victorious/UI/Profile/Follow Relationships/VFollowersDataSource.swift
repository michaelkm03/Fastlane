//
//  VFollowersDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc class VFollowersDataSource: PaginatedDataSource, VUsersDataSource {
    
    let user: VUser
    
    init( user: VUser ) {
        self.user = user
    }
    
    // MARK: - VUsersDataSource
    
    func users() -> NSOrderedSet {
        return self.visibleItems
    }
    
    func loadUsersWithPageType( pageType: VPageType, completion: (NSError? -> ())? = nil ) {
        let userID = self.user.remoteId.integerValue
        
        self.loadPage( pageType,
            createOperation: {
                return UsersFollowingUserOperation(userID: userID)
            },
            completion:{ (results, error, cancelled) in
                completion?( error )
            }
        )
    }
    
    func noContentTitle() -> String {
        return self.user.isCurrentUser ? NSLocalizedString( "NoFollowersTitle", comment: "" ) : NSLocalizedString( "ProfileNoFollowersTitle", comment: "" )
    }
    
    func noContentMessage() -> String {
        return self.user.isCurrentUser ? NSLocalizedString( "NoFollowersMessage", comment: "" ) : NSLocalizedString( "ProfileNoFollowersMessage", comment: "" )
    }
    
    func noContentImage() -> UIImage {
        return UIImage(named: "noFollowersIcon" )!
    }
}
