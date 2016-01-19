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
    private(set) var results: [VUser]?
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete( networkResult: TrendingUsersRequest.ResultType, completion: () -> () ) {
        self.results = []
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            for networkUser in networkResult {
                let persistentUser: VUser = context.v_findOrCreateObject([ "remoteId" : networkUser.userID ])
                persistentUser.populate(fromSourceModel: networkUser)
                context.v_save()
                
                let objectID = persistentUser.objectID
                self.persistentStore.mainContext.v_performBlock() { context in
                    if let user = context.objectWithID( objectID ) as? VUser {
                        self.results?.append(user)
                    }
                }
            }
        }
        completion()
    }
}
