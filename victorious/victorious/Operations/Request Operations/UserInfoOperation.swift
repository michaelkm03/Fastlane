//
//  UserInfoOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UserInfoOperation: RequestOperation {
    
    let request: UserInfoRequest
    
    var user: VUser?
    
    init( userID: Int ) {
        self.request = UserInfoRequest(userID: userID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( user: UserInfoRequest.ResultType, completion:()->() ) {
        persistentStore.backgroundContext.v_performBlock() { context in
            let persistentUser: VUser = context.v_findOrCreateObject( [ "remoteId" : user.userID ])
            persistentUser.populate(fromSourceModel: user)
            context.v_save()
            let objectID = persistentUser.objectID;
            
            self.persistentStore.mainContext.v_performBlock() { context in
                self.user = context.objectWithID(objectID) as? VUser
                completion()
            }
        }
    }
}
