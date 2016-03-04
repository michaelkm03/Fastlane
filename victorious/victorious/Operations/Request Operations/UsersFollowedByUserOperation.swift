//
//  UsersFollowedByUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class UsersFollowedByUserOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    let userID: Int
    
    required init( userID: Int, paginator: StandardPaginator = StandardPaginator() ) {
        self.userID = userID
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = SubscribedToListRequest(userID: userID, paginator: paginator)
            UsersFollowedByUserRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: UsersFollowedByUserOperation, paginator: StandardPaginator) {
        self.init(userID: operation.userID, paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VFollowedUser.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let followPredicate =  NSPredicate(format: "subjectUser.remoteId == %i && objectUser.remoteId != %i",self.userID, self.userID)
            let paginatorPredicate = self.paginator.paginatorPredicate
            fetchRequest.predicate = followPredicate + paginatorPredicate
            let fetchResults: [VFollowedUser] = context.v_executeFetchRequest( fetchRequest )
            self.results = fetchResults.flatMap { $0.objectUser }
        }
    }
}
