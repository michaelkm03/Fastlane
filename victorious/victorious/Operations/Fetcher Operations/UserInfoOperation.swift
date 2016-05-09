//
//  UserInfoOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UserInfoOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: UserInfoRequest!
    
    /// The result (if successfuly), a user loaded from the main context
    var user: VUser?
    
    init(userID: Int, apiPath: String? = nil) {
        self.request = UserInfoRequest(userID: userID, apiPath: apiPath)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( user: UserInfoRequest.ResultType) {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let persistentUser: VUser = context.v_findOrCreateObject([ "remoteId" : user.userID ])
            persistentUser.populate(fromSourceModel: user)
            context.v_save()
            let objectID = persistentUser.objectID;
            
            self.persistentStore.mainContext.v_performBlock() { context in
                self.user = context.objectWithID(objectID) as? VUser
            }
        }
    }
}
