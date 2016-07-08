//
//  CreatorListRemoteOperation.swift
//  victorious
//
//  Created by Tian Lan on 4/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Executes a `CreatorListRequest` to fetch a list of creators from remote endpoint.
/// Then saves the fetched remote result to persistence store.
/// - Note: Does not populate `self.results`
final class CreatorListRemoteOperation: RemoteFetcherOperation {
    
    let request: CreatorListRequest
    
    required init(request: CreatorListRequest) {
        self.request = request
    }
    
    convenience init(urlString: String) {
        let request = CreatorListRequest(urlString: urlString)
        self.init(request: request)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    private func onComplete( users: [User]) {
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            for networkUser in users {
                let persistentUser: VUser = context.v_findOrCreateObject(["remoteId": networkUser.id])
                persistentUser.populate(fromSourceModel: networkUser)
            }
            context.v_save()
        }
    }
}
