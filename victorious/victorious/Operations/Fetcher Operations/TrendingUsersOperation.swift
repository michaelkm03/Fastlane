//
//  TrendingUsersOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class TrendingUsersOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: TrendingUsersRequest! = TrendingUsersRequest()
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete( networkResult: TrendingUsersRequest.ResultType ) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            for networkUser in networkResult {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": networkUser.id])
                persistentUser.populate(fromSourceModel: networkUser)
            }
            context.v_save()
            let userIDs = networkResult.map { $0.id }
            self.results = self.fetchResults(userIDs)
        }
    }
    
    private func fetchResults(networkUserIDs: [Int]) -> [VUser] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VUser.v_entityName())
            let predicate = NSPredicate(format: "remoteId IN %@", networkUserIDs)
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest(fetchRequest)
        }
    }
}
