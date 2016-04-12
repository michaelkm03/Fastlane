//
//  FollowersListOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class UsersFollowingUserOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    
    private var userID: Int
    
    required init( userID: Int, paginator: StandardPaginator = StandardPaginator() ) {
        self.userID = userID
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = FollowersListRequest(userID: userID, paginator: paginator)
            UsersFollowingUserRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: UsersFollowingUserOperation, paginator: StandardPaginator) {
        self.init(userID: operation.userID, paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VFollowedUser.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let followedUserPredicate = NSPredicate(format: "objectUser.remoteId == %i && subjectUser.remoteId != %i", self.userID, self.userID)
            fetchRequest.predicate = followedUserPredicate + self.paginator.paginatorPredicate
            let fetchResults: [VFollowedUser] = context.v_executeFetchRequest( fetchRequest )
            self.results = fetchResults.flatMap { $0.subjectUser }
        }
    }
}
