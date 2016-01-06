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
            completion()
        }
    }
}
