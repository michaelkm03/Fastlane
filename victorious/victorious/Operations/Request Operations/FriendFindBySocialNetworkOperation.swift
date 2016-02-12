//
//  FriendFindBySocialNetworkOperation.swift
//  victorious
//
//  Created by Tian Lan on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FriendFindBySocialNetworkOperation: RequestOperation {
    
    private var request: FriendFindBySocialNetworkRequest
    
    convenience init(token: String) {
        let request = FriendFindBySocialNetworkRequest(socialNetwork: .Facebook(accessToken: token))
        self.init(request: request)
    }
    
    private init(request: FriendFindBySocialNetworkRequest) {
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: self.onComplete, onError: nil)
    }
    
    func onComplete( results: FriendFindByEmailRequest.ResultType, completion:()->() ) {
        let fetcherOperation = FoundFriendsFetcherOperation(users: results, persistentStore: self.persistentStore)
        fetcherOperation.queue { _ in
            self.results = fetcherOperation.results
            completion()
        }
    }
}

/// This operation is used to fetch local persistent results for
/// the network user models we get from FriendFind operations
class FoundFriendsFetcherOperation: FetcherOperation {
    let networkUsers: [User]

    init(users: [User], persistentStore: PersistentStoreType) {
        self.networkUsers = users
        super.init()
        self.persistentStore = persistentStore
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait { context in
            self.results = self.networkUsers.flatMap {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId" : $0.userID])
                persistentUser.populate(fromSourceModel: $0)
                return persistentUser
            }
            context.v_save()
        }
    }
}
