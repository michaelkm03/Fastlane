//
//  TrendingUsersOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class TrendingUsersOperation: RequestOperation {
    
    let request = TrendingUsersRequest()
    private(set) var results: [UserSearchResultObject]?
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete( networkResult: TrendingUsersRequest.ResultType, completion: () -> () ) {
        self.results = networkResult.map { UserSearchResultObject(user: $0) }
        completion()
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            for networkUser in networkResult {
                let localUser: VUser = context.v_findOrCreateObject([ "remoteId" : networkUser.userID])
                localUser.populate(fromSourceModel: networkUser)
            }
            context.v_save()
        }
    }
}
